import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';

enum FieldConfidence { high, medium, low }

FieldConfidence? _confidence(Object? v) =>
    FieldConfidence.values.where((c) => c.name == v).firstOrNull;

Map<String, Object?> _jsonMap(Object? raw) {
  if (raw is Map) return raw.cast<String, Object?>();
  if (raw is String && raw.isNotEmpty) {
    try {
      final v = jsonDecode(raw);
      if (v is Map) return v.cast<String, Object?>();
    } catch (_) {}
  }
  return const {};
}

double? _num(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

/// A confirmed electricity bill (`public.bills`).
@freezed
abstract class Bill with _$Bill {
  const Bill._();

  const factory Bill({
    required String id,
    required String companyId,
    required String leadId,
    String? photoId,
    String? discom,
    String? consumerNumber,
    String? customerName,
    String? tariffCategory,
    double? sanctionedLoadKw,
    String? billingPeriod,
    @Default({}) Map<String, double> unitsMonthly,
    double? avgMonthlyUnits,
    double? billAmount,
    @Default({}) Map<String, FieldConfidence> aiConfidence,
    @Default('manual') String source,
    DateTime? confirmedAt,
    DateTime? createdAt,
  }) = _Bill;

  factory Bill.fromRow(Map<String, Object?> r) => Bill(
    id: r['id']! as String,
    companyId: r['company_id']! as String,
    leadId: r['lead_id']! as String,
    photoId: r['photo_id'] as String?,
    discom: r['discom'] as String?,
    consumerNumber: r['consumer_number'] as String?,
    customerName: r['customer_name'] as String?,
    tariffCategory: r['tariff_category'] as String?,
    sanctionedLoadKw: _num(r['sanctioned_load_kw']),
    billingPeriod: r['billing_period'] as String?,
    unitsMonthly: {
      for (final e in _jsonMap(r['units_monthly']).entries)
        if (_num(e.value) != null) e.key: _num(e.value)!,
    },
    avgMonthlyUnits: _num(r['avg_monthly_units']),
    billAmount: _num(r['bill_amount']),
    aiConfidence: {
      for (final e in _jsonMap(r['ai_confidence']).entries)
        if (_confidence(e.value) != null) e.key: _confidence(e.value)!,
    },
    source: (r['source'] as String?) ?? 'manual',
    confirmedAt: DateTime.tryParse((r['confirmed_at'] as String?) ?? ''),
    createdAt: DateTime.tryParse((r['created_at'] as String?) ?? ''),
  );

  /// Usage by calendar month (Jan..Dec) when the bill printed a full year of
  /// history; used for month-by-month savings. Null otherwise.
  List<double>? get history12 {
    if (unitsMonthly.length < 12) return null;
    final keys = unitsMonthly.keys.toList()..sort();
    final last12 = keys.sublist(keys.length - 12);
    // Order Jan..Dec to line up with generation months.
    final byMonth = List<double>.filled(12, 0);
    for (final k in last12) {
      final m = int.tryParse(k.split('-').last);
      if (m != null && m >= 1 && m <= 12) byMonth[m - 1] = unitsMonthly[k]!;
    }
    return byMonth;
  }
}

/// What the bill form edits (prefilled from a scan or empty).
@freezed
abstract class BillInput with _$BillInput {
  const factory BillInput({
    @Default('') String discom,
    @Default('') String consumerNumber,
    @Default('') String customerName,
    @Default('') String tariffCategory,
    double? sanctionedLoadKw,
    @Default('') String billingPeriod,
    @Default({}) Map<String, double> unitsMonthly,
    double? avgMonthlyUnits,
    double? billAmount,
    @Default({}) Map<String, FieldConfidence> confidence,
    String? photoId,
    @Default('manual') String source,
  }) = _BillInput;

  factory BillInput.fromBill(Bill b) => BillInput(
    discom: b.discom ?? '',
    consumerNumber: b.consumerNumber ?? '',
    customerName: b.customerName ?? '',
    tariffCategory: b.tariffCategory ?? '',
    sanctionedLoadKw: b.sanctionedLoadKw,
    billingPeriod: b.billingPeriod ?? '',
    unitsMonthly: b.unitsMonthly,
    avgMonthlyUnits: b.avgMonthlyUnits,
    billAmount: b.billAmount,
    confidence: b.aiConfidence,
    photoId: b.photoId,
    source: b.source,
  );

  /// Prefill from the `bill-scan` function response.
  factory BillInput.fromScan(Map<String, Object?> json, {String? photoId}) {
    final e = _jsonMap(json['extraction']);
    final units = _jsonMap(json['units_monthly']);
    final conf = _jsonMap(e['confidence']);
    return BillInput(
      discom: (e['discom'] as String?) ?? '',
      consumerNumber: (e['consumer_number'] as String?) ?? '',
      customerName: (e['customer_name'] as String?) ?? '',
      tariffCategory: (e['tariff_category'] as String?) ?? '',
      sanctionedLoadKw: _num(e['sanctioned_load_kw']),
      billingPeriod: (e['billing_period'] as String?) ?? '',
      unitsMonthly: {
        for (final u in units.entries)
          if (_num(u.value) != null) u.key: _num(u.value)!,
      },
      avgMonthlyUnits: _num(json['avg_monthly_units']),
      billAmount: _num(e['bill_amount']),
      confidence: {
        for (final c in conf.entries)
          if (_confidence(c.value) != null) c.key: _confidence(c.value)!,
      },
      photoId: photoId,
      source: 'scan',
    );
  }
}

/// Average of the month values, rounded; null when there are none.
double? averageUnits(Map<String, double> months) => months.isEmpty
    ? null
    : (months.values.fold<double>(0, (a, b) => a + b) / months.length)
          .roundToDouble();

enum ScanStatus { pending, done, failed }

/// A queued bill scan (local-only `action_queue` row).
class ScanJob {
  const ScanJob({
    required this.id,
    required this.leadId,
    required this.photoId,
    required this.status,
    required this.attempts,
    this.lastError,
    this.result,
  });

  final String id;
  final String leadId;
  final String photoId;
  final ScanStatus status;
  final int attempts;
  final String? lastError;
  final Map<String, Object?>? result;

  factory ScanJob.fromRow(Map<String, Object?> r) => ScanJob(
    id: r['id']! as String,
    leadId: r['lead_id']! as String,
    photoId: r['photo_id']! as String,
    status: ScanStatus.values.firstWhere(
      (s) => s.name == r['status'],
      orElse: () => ScanStatus.pending,
    ),
    attempts: (r['attempts'] as int?) ?? 0,
    lastError: r['last_error'] as String?,
    result: _jsonMap(r['result']).isEmpty ? null : _jsonMap(r['result']),
  );
}
