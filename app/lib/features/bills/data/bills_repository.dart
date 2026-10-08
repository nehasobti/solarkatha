import 'dart:convert';

import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/powersync/powersync_providers.dart';
import '../../../data/powersync/schema.dart';
import '../domain/bill.dart';

part 'bills_repository.g.dart';

const _uuid = Uuid();
String _now() => DateTime.now().toUtc().toIso8601String();
String? _blank(String s) => s.trim().isEmpty ? null : s.trim();

/// Bills and the offline bill-scan queue, on the device database.
class BillsRepository {
  BillsRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<List<Bill>> watchBills(String leadId) => _db
      .watch(
        'SELECT * FROM $billsTable WHERE lead_id = ? AND deleted_at IS NULL '
        'ORDER BY created_at DESC',
        parameters: [leadId],
      )
      .map((rows) => rows.map(Bill.fromRow).toList());

  Future<Bill?> getBill(String id) async {
    final r = await _db.getOptional('SELECT * FROM $billsTable WHERE id = ?', [
      id,
    ]);
    return r == null ? null : Bill.fromRow(r);
  }

  /// Other leads in this company with the same consumer number (one central
  /// subsidy per household).
  Future<int> countDuplicateConsumers({
    required String consumerNumber,
    required String leadId,
  }) async {
    if (consumerNumber.trim().isEmpty) return 0;
    final r = await _db.get(
      'SELECT COUNT(DISTINCT lead_id) AS n FROM $billsTable '
      'WHERE consumer_number = ? AND lead_id != ? AND deleted_at IS NULL',
      [consumerNumber.trim(), leadId],
    );
    return r['n'] as int;
  }

  Future<String> saveBill({
    String? id,
    required String leadId,
    required String companyId,
    required String userId,
    required BillInput input,
  }) async {
    final now = _now();
    final fields = <String, Object?>{
      'discom': _blank(input.discom),
      'consumer_number': _blank(input.consumerNumber),
      'customer_name': _blank(input.customerName),
      'tariff_category': _blank(input.tariffCategory),
      'sanctioned_load_kw': input.sanctionedLoadKw,
      'billing_period': _blank(input.billingPeriod),
      'units_monthly': input.unitsMonthly.isEmpty
          ? null
          : jsonEncode(input.unitsMonthly),
      'avg_monthly_units': input.avgMonthlyUnits,
      'bill_amount': input.billAmount,
      'ai_confidence': input.confidence.isEmpty
          ? null
          : jsonEncode({
              for (final e in input.confidence.entries) e.key: e.value.name,
            }),
      'source': input.source,
      'photo_id': input.photoId,
      'confirmed_by': userId,
      'confirmed_at': now,
      'updated_at': now,
    };
    if (id != null) {
      await _db.execute(
        'UPDATE $billsTable SET ${fields.keys.map((k) => '$k = ?').join(', ')} '
        'WHERE id = ?',
        [...fields.values, id],
      );
      return id;
    }
    final newId = _uuid.v4();
    final all = {
      ...fields,
      'id': newId,
      'lead_id': leadId,
      'company_id': companyId,
      'created_at': now,
    };
    await _db.execute(
      'INSERT INTO $billsTable (${all.keys.join(', ')}) '
      'VALUES (${List.filled(all.length, '?').join(', ')})',
      all.values.toList(),
    );
    return newId;
  }

  Future<void> deleteBill(String id) => _db.execute(
    'UPDATE $billsTable SET deleted_at = ?, updated_at = ? WHERE id = ?',
    [_now(), _now(), id],
  );

  // ---------------------------------------------------------------------------
  // Scan queue
  // ---------------------------------------------------------------------------

  Stream<List<ScanJob>> watchScans(String leadId) => _db
      .watch(
        "SELECT * FROM $actionQueueTable WHERE kind = 'bill_scan' "
        'AND lead_id = ? ORDER BY created_at DESC',
        parameters: [leadId],
      )
      .map((rows) => rows.map(ScanJob.fromRow).toList());

  Future<ScanJob?> getScan(String id) async {
    final r = await _db.getOptional(
      'SELECT * FROM $actionQueueTable WHERE id = ?',
      [id],
    );
    return r == null ? null : ScanJob.fromRow(r);
  }

  Future<void> queueScan({
    required String leadId,
    required String companyId,
    required String photoId,
  }) => _db.execute(
    'INSERT INTO $actionQueueTable '
    '(id, kind, lead_id, photo_id, company_id, status, attempts, created_at, updated_at) '
    "VALUES (?, 'bill_scan', ?, ?, ?, 'pending', 0, ?, ?)",
    [_uuid.v4(), leadId, photoId, companyId, _now(), _now()],
  );

  Future<void> retryScan(String id) => _db.execute(
    "UPDATE $actionQueueTable SET status = 'pending', attempts = 0, "
    'last_error = NULL, updated_at = ? WHERE id = ?',
    [_now(), id],
  );

  Future<void> removeScan(String id) =>
      _db.execute('DELETE FROM $actionQueueTable WHERE id = ?', [id]);
}

@Riverpod(keepAlive: true)
BillsRepository billsRepository(Ref ref) =>
    BillsRepository(ref.watch(powerSyncDbProvider));
