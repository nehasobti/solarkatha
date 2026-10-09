import 'dart:convert';

import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/powersync/powersync_providers.dart';
import '../../../data/supabase/supabase_providers.dart';
import '../../projects/domain/project.dart';

part 'admin_repository.g.dart';

const _uuid = Uuid();
String _now() => DateTime.now().toUtc().toIso8601String();

/// Owner dashboard numbers.
class DashboardStats {
  const DashboardStats({
    this.kwSold = 0,
    this.revenue = 0,
    this.subsidiesPending = 0,
    this.activeProjects = 0,
    this.byStage = const {},
  });

  final double kwSold;
  final double revenue;
  final int subsidiesPending;
  final int activeProjects;
  final Map<StageKind, int> byStage;
}

class Member {
  const Member({
    required this.id,
    required this.name,
    required this.role,
    required this.active,
    this.phone,
    this.leads = 0,
    this.won = 0,
    this.kw = 0,
  });

  final String id;
  final String name;
  final String role;
  final bool active;
  final String? phone;
  final int leads;
  final int won;
  final double kw;
}

class Invite {
  const Invite({required this.id, required this.role, this.name, this.phone});

  final String id;
  final String role;
  final String? name;
  final String? phone;
}

/// A config row: either the platform default (companyId null) or the
/// company's own override.
class ConfigRow {
  const ConfigRow(this.data);

  final Map<String, Object?> data;
  String get id => data['id']! as String;
  bool get own => data['company_id'] != null;
  Object? operator [](String k) => data[k];
}

class AdminRepository {
  AdminRepository(this._db, this._client);

  final PowerSyncDatabase _db;
  final SupabaseClient _client;

  Stream<DashboardStats> watchStats() => _db
      .watch(
        'SELECT '
        '(SELECT COALESCE(SUM(system_kw), 0) FROM projects WHERE deleted_at IS NULL) AS kw, '
        "(SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'paid') AS revenue, "
        '(SELECT COUNT(*) FROM projects WHERE deleted_at IS NULL '
        ' AND subsidy_amount_received IS NULL) AS subsidy_pending, '
        '(SELECT COUNT(*) FROM projects WHERE deleted_at IS NULL '
        ' AND completed_at IS NULL) AS active, '
        '(SELECT json_group_object(current_stage, n) FROM (SELECT current_stage, COUNT(*) AS n '
        ' FROM projects WHERE deleted_at IS NULL AND completed_at IS NULL '
        ' GROUP BY current_stage)) AS by_stage',
      )
      .map((rows) {
        final r = rows.first;
        final by = <StageKind, int>{};
        final m = jsonDecode((r['by_stage'] as String?) ?? '{}');
        if (m is Map) {
          for (final e in m.entries) {
            final k = StageKind.values
                .where((s) => s.dbValue == e.key)
                .firstOrNull;
            if (k != null) by[k] = (e.value as num).toInt();
          }
        }
        return DashboardStats(
          kwSold: (r['kw'] as num).toDouble(),
          revenue: (r['revenue'] as num).toDouble(),
          subsidiesPending: (r['subsidy_pending'] as num).toInt(),
          activeProjects: (r['active'] as num).toInt(),
          byStage: by,
        );
      });

  Future<List<Map<String, Object?>>> leadsForExport() => _db.getAll(
    'SELECT l.name, l.phone, l.district, l.state_code, l.source, l.status, '
    'p.name AS assigned_to, l.created_at, l.next_follow_up_at '
    'FROM leads l LEFT JOIN profiles p ON p.id = l.assigned_to '
    'WHERE l.deleted_at IS NULL ORDER BY l.created_at DESC',
  );

  // --- Team -----------------------------------------------------------------

  Stream<List<Member>> watchMembers() => _db
      .watch(
        'SELECT p.id, p.name, p.role, p.active, p.phone, '
        '(SELECT COUNT(*) FROM leads l WHERE l.assigned_to = p.id AND l.deleted_at IS NULL) AS leads, '
        "(SELECT COUNT(*) FROM leads l WHERE l.assigned_to = p.id AND l.status = 'won' AND l.deleted_at IS NULL) AS won, "
        '(SELECT COALESCE(SUM(pr.system_kw), 0) FROM projects pr JOIN leads l ON l.id = pr.lead_id '
        ' WHERE l.assigned_to = p.id AND pr.deleted_at IS NULL) AS kw '
        'FROM profiles p ORDER BY p.active DESC, p.name',
      )
      .map(
        (rows) => [
          for (final r in rows)
            Member(
              id: r['id']! as String,
              name: (r['name'] as String?) ?? '',
              role: (r['role'] as String?) ?? '',
              active: r['active'] == 1,
              phone: r['phone'] as String?,
              leads: (r['leads'] as num).toInt(),
              won: (r['won'] as num).toInt(),
              kw: (r['kw'] as num).toDouble(),
            ),
        ],
      );

  Future<void> setActive(String profileId, bool active) => _db.execute(
    'UPDATE profiles SET active = ? WHERE id = ?',
    [active ? 1 : 0, profileId],
  );

  Future<void> setRole(String profileId, String role) => _db.execute(
    'UPDATE profiles SET role = ? WHERE id = ?',
    [role, profileId],
  );

  /// Invites live only on the server (they're not synced).
  Future<List<Invite>> invites(String companyId) async {
    final rows = await _client
        .from('team_invites')
        .select('id, name, phone, role')
        .eq('company_id', companyId)
        .isFilter('accepted_at', null)
        .isFilter('revoked_at', null)
        .order('created_at');
    return [
      for (final r in rows)
        Invite(
          id: r['id'] as String,
          role: r['role'] as String,
          name: r['name'] as String?,
          phone: r['phone'] as String?,
        ),
    ];
  }

  Future<void> invite({
    required String companyId,
    required String invitedBy,
    required String name,
    required String phone,
    required String role,
  }) => _client.from('team_invites').insert({
    'company_id': companyId,
    'invited_by': invitedBy,
    'name': name,
    'phone': phone,
    'role': role,
  });

  Future<void> revokeInvite(String id) =>
      _client.from('team_invites').update({'revoked_at': _now()}).eq('id', id);

  // --- Company / branding -----------------------------------------------------

  Stream<Map<String, Object?>?> watchCompany(String id) => _db
      .watch('SELECT * FROM companies WHERE id = ?', parameters: [id])
      .map((rows) => rows.firstOrNull);

  Future<void> updateCompany(String id, Map<String, Object?> fields) {
    final cols = fields.keys.map((k) => '$k = ?').join(', ');
    return _db.execute('UPDATE companies SET $cols WHERE id = ?', [
      ...fields.values,
      id,
    ]);
  }

  // --- Config tables ----------------------------------------------------------

  /// Rows of [table]: the company's own plus the defaults.
  Stream<List<ConfigRow>> watchConfig(String table, {String orderBy = 'id'}) =>
      _db
          .watch('SELECT * FROM $table ORDER BY $orderBy')
          .map((rows) => rows.map(ConfigRow.new).toList());

  /// Writes the company's value for an app_config [key] (creating the
  /// override row the first time).
  Future<void> setAppConfig(String companyId, String key, Object? value) async {
    final json = jsonEncode(value);
    final own = await _db.getOptional(
      'SELECT id FROM app_config WHERE key = ? AND company_id = ?',
      [key, companyId],
    );
    if (own == null) {
      await _db.execute(
        'INSERT INTO app_config (id, company_id, key, value) VALUES (?, ?, ?, ?)',
        [_uuid.v4(), companyId, key, json],
      );
    } else {
      await _db.execute('UPDATE app_config SET value = ? WHERE id = ?', [
        json,
        own['id'],
      ]);
    }
  }

  /// Inserts or updates a company-owned row of [table].
  Future<void> saveRow(
    String table,
    String companyId,
    Map<String, Object?> fields, {
    String? id,
  }) async {
    if (id == null) {
      final all = {'id': _uuid.v4(), 'company_id': companyId, ...fields};
      await _db.execute(
        'INSERT INTO $table (${all.keys.join(', ')}) '
        'VALUES (${List.filled(all.length, '?').join(', ')})',
        all.values.toList(),
      );
    } else {
      final cols = fields.keys.map((k) => '$k = ?').join(', ');
      await _db.execute(
        'UPDATE $table SET $cols WHERE id = ? AND company_id = ?',
        [...fields.values, id, companyId],
      );
    }
  }

  /// Removes a company override (the default applies again).
  Future<void> deleteRow(String table, String id) => _db.execute(
    'DELETE FROM $table WHERE id = ? AND company_id IS NOT NULL',
    [id],
  );
}

@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) => AdminRepository(
  ref.watch(powerSyncDbProvider),
  ref.watch(supabaseClientProvider),
);

@riverpod
Stream<DashboardStats> dashboardStats(Ref ref) =>
    ref.watch(adminRepositoryProvider).watchStats();

@riverpod
Stream<List<Member>> members(Ref ref) =>
    ref.watch(adminRepositoryProvider).watchMembers();

@riverpod
Stream<List<ConfigRow>> configRows(Ref ref, String table, String orderBy) =>
    ref.watch(adminRepositoryProvider).watchConfig(table, orderBy: orderBy);

@riverpod
Stream<Map<String, Object?>?> company(Ref ref, String id) =>
    ref.watch(adminRepositoryProvider).watchCompany(id);
