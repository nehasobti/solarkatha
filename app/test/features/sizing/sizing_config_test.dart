import 'package:flutter_test/flutter_test.dart';
import 'package:solar_core/solar_core.dart';
import 'package:solarkatha/features/sizing/domain/sizing_calculator.dart';
import 'package:solarkatha/features/sizing/domain/sizing_config.dart';

import '../../helpers/fake_bills.dart';

void main() {
  final config = seededSizingConfig();

  test('reads seeded config rows (JSON text from the device DB)', () {
    expect(config.solar.sqmPerKw, 10);
    expect(config.solar.shadingLossPct[ShadingLevel.high], 15);
    expect(applyRule(config.central, 3).amount, 78000);
    expect(applyRule(config.stateRule('UP')!, 3).amount, 30000);
    expect(config.stateRule('RJ'), isNull);
    expect(config.tariffFor('UP', 'MVVNL'), isNotNull);
    expect(config.tariffFor('RJ', null), isNull);
    expect(config.loans.map((l) => l.id), ['sbi', 'other']);
  });

  test('company rows override defaults', () {
    final c = SizingConfig.fromRows(
      companyId: 'c1',
      appConfig: [
        {'company_id': null, 'key': 'sqm_per_kw', 'value': '10'},
        {'company_id': 'c1', 'key': 'sqm_per_kw', 'value': '8'},
        {'company_id': 'other', 'key': 'sqm_per_kw', 'value': '1'},
        for (final e in {
          'default_yield_kwh_per_kw_day': '4.2',
          'shading_loss_pct': '{"none": 0}',
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
          'slabs': '[{"upto_kw": null, "per_kw": 1}]',
        },
      ],
      tariffs: const [],
      loanPresets: const [],
    );
    expect(c.solar.sqmPerKw, 8);
  });

  test('missing central rule means config not synced', () {
    expect(
      () => SizingConfig.fromRows(
        companyId: 'c1',
        appConfig: const [],
        subsidyRules: const [],
        tariffs: const [],
        loanPresets: const [],
      ),
      throwsFormatException,
    );
  });

  test('expired subsidy rules are ignored', () {
    expect(
      () => SizingConfig.fromRows(
        companyId: 'c1',
        appConfig: const [],
        subsidyRules: [
          {
            'company_id': null,
            'scope': 'central',
            'slabs': '[]',
            'valid_to': '2020-01-01',
          },
        ],
        tariffs: const [],
        loanPresets: const [],
      ),
      throwsFormatException,
    );
  });

  test('without a tariff, savings use the bill\'s average rate', () {
    final calc = SizingCalculator(
      config,
      SizingInputs(
        avgMonthlyUnits: 300,
        monthlyPerKw: fallbackMonthlyPerKw(4.2),
        stateCode: 'RJ',
        billAmount: 2400,
      ),
    );
    expect(calc.tariffSource, TariffSource.fromBill);
    expect(calc.tariff!.averageRate(300), 8);
    final none = SizingCalculator(
      config,
      SizingInputs(
        avgMonthlyUnits: 300,
        monthlyPerKw: fallbackMonthlyPerKw(4.2),
        stateCode: 'RJ',
      ),
    );
    expect(none.tariffSource, TariffSource.none);
    expect(none.evaluate(3).savings, isNull);
  });
}
