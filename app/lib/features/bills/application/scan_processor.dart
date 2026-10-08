import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/powersync/powersync_providers.dart';
import '../../../data/powersync/schema.dart';
import '../../../data/supabase/supabase_providers.dart';
import '../../leads/application/leads_providers.dart';

part 'scan_processor.g.dart';

final _log = Logger('ScanProcessor');

const maxScanAttempts = 5;

/// Runs queued bill scans once the phone is online and the bill photo has
/// uploaded. Retries network/server failures; gives up on rejected requests
/// so the rep can enter the values by hand.
@Riverpod(keepAlive: true)
class ScanProcessor extends _$ScanProcessor {
  Timer? _timer;
  bool _running = false;

  @override
  void build() {
    final member = ref.watch(currentMemberProvider);
    if (member == null) return;
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => run());
    ref.listen(syncStatusProvider, (prev, next) {
      final was = prev?.value?.connected ?? false;
      if (!was && (next.value?.connected ?? false)) run();
    });
    ref.onDispose(() => _timer?.cancel());
    Future.microtask(run);
  }

  Future<void> run() async {
    if (_running) return;
    _running = true;
    try {
      final db = ref.read(powerSyncDbProvider);
      final rows = await db.getAll(
        'SELECT q.*, a.state AS photo_state FROM $actionQueueTable q '
        'LEFT JOIN ${AttachmentsQueueTable.defaultTableName} a ON a.id = q.photo_id '
        "WHERE q.kind = 'bill_scan' AND q.status = 'pending' ORDER BY q.created_at",
      );
      for (final row in rows) {
        final state = row['photo_state'] as int?;
        final uploaded =
            state == AttachmentState.synced.index ||
            state == AttachmentState.archived.index;
        if (!uploaded) continue; // photo still on the phone
        await _process(row);
      }
    } catch (e, s) {
      _log.warning('Scan queue run failed', e, s);
    } finally {
      _running = false;
    }
  }

  Future<void> _process(Map<String, Object?> row) async {
    final db = ref.read(powerSyncDbProvider);
    final id = row['id']! as String;
    final attempts = ((row['attempts'] as int?) ?? 0) + 1;
    final now = DateTime.now().toUtc().toIso8601String();
    final path =
        'company/${row['company_id']}/lead-photos/${row['photo_id']}.jpg';
    try {
      final res = await ref
          .read(supabaseClientProvider)
          .functions
          .invoke('bill-scan', body: {'path': path});
      await db.execute(
        "UPDATE $actionQueueTable SET status = 'done', attempts = ?, "
        'result = ?, last_error = NULL, updated_at = ? WHERE id = ?',
        [attempts, jsonEncode(res.data), now, id],
      );
    } on FunctionException catch (e) {
      final message =
          _message(e.details) ?? e.reasonPhrase ?? 'Error ${e.status}';
      // 404: photo not in storage yet; 5xx: try again later.
      final retry = e.status == 404 || e.status >= 500;
      final failed = !retry || attempts >= maxScanAttempts;
      await db.execute(
        'UPDATE $actionQueueTable SET status = ?, attempts = ?, '
        'last_error = ?, updated_at = ? WHERE id = ?',
        [failed ? 'failed' : 'pending', attempts, message, now, id],
      );
    } catch (e) {
      // Network: keep pending until the attempt limit.
      await db.execute(
        'UPDATE $actionQueueTable SET status = ?, attempts = ?, '
        'last_error = ?, updated_at = ? WHERE id = ?',
        [
          attempts >= maxScanAttempts ? 'failed' : 'pending',
          attempts,
          e.toString(),
          now,
          id,
        ],
      );
    }
  }

  static String? _message(Object? details) {
    if (details is Map && details['message'] is String) {
      return details['message'] as String;
    }
    return null;
  }
}
