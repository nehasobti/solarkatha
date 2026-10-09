import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';

final _log = Logger('SupabaseConnector');

/// Postgres errors that will never succeed on retry (constraint or RLS
/// violations). Those changes are dropped so they don't block the queue.
final _fatalCodes = [
  RegExp(r'^22...$'), // data exception
  RegExp(r'^23...$'), // integrity constraint violation
  RegExp(r'^42501$'), // insufficient privilege (RLS)
];

/// jsonb columns are stored as JSON text locally; send them as JSON values so
/// Postgres doesn't keep them as a quoted string.
const jsonbColumns = <String, Set<String>>{
  'app_config': {'value'},
  'subsidy_rules': {'slabs'},
  'tariffs': {'slabs'},
  'bills': {'units_monthly', 'ai_confidence'},
  'proposals': {'loan', 'est_generation', 'compliance'},
  'sites': {'roof_polygons'},
  'notifications': {'data'},
};

/// Decodes the jsonb columns of [table] in [data].
Map<String, dynamic> encodeRow(String table, Map<String, dynamic> data) {
  final cols = jsonbColumns[table];
  if (cols == null) return data;
  return {
    for (final e in data.entries)
      e.key: cols.contains(e.key) && e.value is String
          ? _tryDecode(e.value as String)
          : e.value,
  };
}

Object? _tryDecode(String v) {
  try {
    return jsonDecode(v);
  } on FormatException {
    return v;
  }
}

/// Uploads local changes to Supabase and gives PowerSync the user's JWT.
class SupabaseConnector extends PowerSyncBackendConnector {
  SupabaseConnector(this._client);

  final SupabaseClient _client;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = _client.auth.currentSession;
    if (session == null || Env.powersyncUrl.isEmpty) return null;
    return PowerSyncCredentials(
      endpoint: Env.powersyncUrl,
      token: session.accessToken,
      userId: session.user.id,
    );
  }

  @override
  void invalidateCredentials() {
    // Refresh the Supabase session so the next fetch gets a fresh token.
    _client.auth.refreshSession().ignore();
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    CrudEntry? last;
    try {
      for (final op in transaction.crud) {
        last = op;
        final table = _client.from(op.table);
        switch (op.op) {
          case UpdateType.put:
            await table.upsert(
              encodeRow(op.table, {...?op.opData, 'id': op.id}),
            );
          case UpdateType.patch:
            await table.update(encodeRow(op.table, op.opData!)).eq('id', op.id);
          case UpdateType.delete:
            await table.delete().eq('id', op.id);
        }
      }
      await transaction.complete();
    } on PostgrestException catch (e) {
      if (_fatalCodes.any((re) => re.hasMatch(e.code ?? ''))) {
        _log.severe('Dropping rejected change $last: ${e.message}');
        await transaction.complete();
      } else {
        rethrow;
      }
    }
  }
}
