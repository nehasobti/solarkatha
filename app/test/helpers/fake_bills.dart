import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:solar_core/solar_core.dart';
import 'package:solarkatha/features/bills/application/scan_processor.dart';
import 'package:solarkatha/features/bills/data/bills_repository.dart';
import 'package:solarkatha/features/bills/domain/bill.dart';
import 'package:solarkatha/features/sizing/data/sizing_repository.dart';
import 'package:solarkatha/features/sizing/domain/sizing_config.dart';

/// In-memory bills + scan queue.
class FakeBillsRepository extends Mock implements BillsRepository {
  FakeBillsRepository({
    List<Bill> bills = const [],
    List<ScanJob> scans = const [],
  }) : _bills = [...bills],
       _scans = [...scans];

  final List<Bill> _bills;
  final List<ScanJob> _scans;
  final saved = <BillInput>[];
  final _changes = StreamController<void>.broadcast();

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<Bill>> watchBills(String leadId) =>
      _live(() => _bills.where((b) => b.leadId == leadId).toList());

  @override
  Stream<List<ScanJob>> watchScans(String leadId) =>
      _live(() => _scans.where((s) => s.leadId == leadId).toList());

  @override
  Future<Bill?> getBill(String id) async =>
      _bills.where((b) => b.id == id).firstOrNull;

  @override
  Future<ScanJob?> getScan(String id) async =>
      _scans.where((s) => s.id == id).firstOrNull;

  @override
  Future<int> countDuplicateConsumers({
    required String consumerNumber,
    required String leadId,
  }) async => _bills
      .where((b) => b.consumerNumber == consumerNumber && b.leadId != leadId)
      .length;

  @override
  Future<String> saveBill({
    String? id,
    required String leadId,
    required String companyId,
    required String userId,
    required BillInput input,
  }) async {
    saved.add(input);
    _changes.add(null);
    return id ?? 'bill-${saved.length}';
  }

  @override
  Future<void> removeScan(String id) async {
    _scans.removeWhere((s) => s.id == id);
    _changes.add(null);
  }
}

class FakeScanProcessor extends ScanProcessor {
  @override
  void build() {}
}

/// Generation without the network: the configured flat yield.
class FakeGenerationService extends Mock implements GenerationService {
  @override
  Future<GenerationEstimate> estimate({
    required double? lat,
    required double? lng,
    required SolarConfig config,
  }) async => GenerationEstimate(
    fallbackMonthlyPerKw(config.defaultYieldKwhPerKwDay),
    fromPvgis: false,
  );
}

/// The same rows as the seeded database (migration 20261006000000).
SizingConfig seededSizingConfig() => SizingConfig.fromRows(
  companyId: 'c1',
  appConfig: [
    for (final e in {
      'sqm_per_kw': '10',
      'default_yield_kwh_per_kw_day': '4.2',
      'shading_loss_pct': '{"none": 0, "low": 3, "medium": 8, "high": 15}',
      'degradation_pct': '0.5',
      'tariff_escalation_pct': '3',
      'export_rate_per_kwh': '2',
      'lifetime_years': '25',
      'default_price_per_kw': '60000',
    }.entries)
      {'company_id': null, 'key': e.key, 'value': e.value},
  ],
  subsidyRules: [
    {
      'company_id': null,
      'scope': 'central',
      'segment': 'residential',
      'slabs':
          '[{"upto_kw": 2, "per_kw": 30000}, {"upto_kw": 3, "per_kw": 18000}]',
      'cap_amount': 78000,
      'valid_from': '2024-02-13',
    },
    {
      'company_id': null,
      'scope': 'UP',
      'segment': 'residential',
      'slabs': '[{"upto_kw": null, "per_kw": 15000}]',
      'cap_amount': 30000,
      'valid_from': '2024-04-01',
    },
  ],
  tariffs: [
    {
      'company_id': null,
      'state_code': 'UP',
      'discom': null,
      'slabs': '[{"upto_units": 100, "rate": 5.5}, {"upto_units": 150, "rate": 5.5}, {"upto_units": 300, "rate": 6.0}, {"upto_units": null, "rate": 6.5}]',
      'fixed_charge': 110,
    },
  ],
  loanPresets: [
    {
      'id': 'sbi',
      'company_id': null,
      'bank_name': 'SBI Surya Ghar (up to 3 kW)',
      'rate_pct': 7.0,
      'max_years': 10,
      'sort': 1,
    },
    {
      'id': 'other',
      'company_id': null,
      'bank_name': 'Other bank / NBFC',
      'rate_pct': 10.5,
      'max_years': 7,
      'sort': 3,
    },
  ],
);
