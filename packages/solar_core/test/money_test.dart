import 'package:solar_core/solar_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('EMI', () {
    // Known values from standard bank EMI calculators.
    test('₹1,00,000 at 10% for 12 months → ₹8,791.59', () {
      final r = calculateEmi(principal: 100000, annualRatePct: 10, months: 12);
      expect(r.emi, closeTo(8791.59, 0.01));
      expect(r.totalPayable, closeTo(105499.06, 0.05));
      expect(r.totalInterest, closeTo(5499.06, 0.05));
    });

    test('₹5,00,000 at 8.5% for 60 months → ₹10,258.27', () {
      final r = calculateEmi(principal: 500000, annualRatePct: 8.5, months: 60);
      expect(r.emi, closeTo(10258.27, 0.01));
    });

    test('₹1,00,000 at 7% for 120 months → ₹1,161.08', () {
      final r = calculateEmi(principal: 100000, annualRatePct: 7, months: 120);
      expect(r.emi, closeTo(1161.08, 0.01));
    });

    test('0% interest is principal ÷ months', () {
      final r = calculateEmi(principal: 120000, annualRatePct: 0, months: 12);
      expect(r.emi, 10000);
      expect(r.totalInterest, 0);
    });

    test('rejects bad input', () {
      expect(
        () => calculateEmi(principal: 1, annualRatePct: 7, months: 0),
        throwsArgumentError,
      );
      expect(
        () => calculateEmi(principal: -1, annualRatePct: 7, months: 12),
        throwsArgumentError,
      );
      expect(
        () => calculateEmi(principal: 1, annualRatePct: -1, months: 12),
        throwsArgumentError,
      );
    });
  });

  group('tariff', () {
    test('telescopic slabs', () {
      expect(simpleTariff.energyCharge(0), 0);
      expect(simpleTariff.energyCharge(50), 250);
      expect(simpleTariff.energyCharge(250), 500 + 150 * 6);
      expect(simpleTariff.energyCharge(400), 500 + 1200 + 700);
      expect(simpleTariff.monthlyBill(50), 360);
      expect(simpleTariff.averageRate(400), 6);
      expect(simpleTariff.averageRate(0), 0);
    });

    test('units beyond the last bounded slab use its rate', () {
      const t = Tariff(slabs: [TariffSlab(uptoUnits: 100, rate: 5)]);
      expect(t.energyCharge(150), 750);
    });

    test('rate multiplier scales energy charge', () {
      expect(
        simpleTariff.energyCharge(50, rateMultiplier: 1.1),
        closeTo(275, 1e-9),
      );
    });

    test('slabs parse from JSON', () {
      final s = TariffSlab.fromJson({'upto_units': 100, 'rate': 5.5});
      expect(s.uptoUnits, 100);
      expect(s.rate, 5.5);
    });
  });

  group('savings and payback', () {
    test('saving is capped at own usage; surplus earns export rate', () {
      expect(
        monthSaving(
          usage: 300,
          generation: 300,
          tariff: simpleTariff,
          exportRate: 2,
        ),
        1700,
      );
      expect(
        monthSaving(
          usage: 300,
          generation: 400,
          tariff: simpleTariff,
          exportRate: 2,
        ),
        1900,
      );
      // Partial offset removes the most expensive units first.
      expect(
        monthSaving(
          usage: 300,
          generation: 100,
          tariff: simpleTariff,
          exportRate: 2,
        ),
        600,
      );
    });

    test('flat case pays back in exactly 2 years', () {
      final r = projectSavings(
        monthlyUsage: List.filled(12, 300),
        monthlyGenerationYear1: List.filled(12, 300),
        tariff: simpleTariff,
        exportRate: 2,
        escalationPctPerYear: 0,
        degradationPctPerYear: 0,
        years: 25,
        netPrice: 40800,
      );
      expect(r.annualSavingYear1, 20400);
      expect(r.monthlySavingYear1, 1700);
      expect(r.paybackYears, closeTo(2.0, 1e-9));
      expect(r.lifetimeSaving, 20400 * 25);
      expect(r.years, hasLength(25));
    });

    test('escalation raises later savings; degradation lowers them', () {
      final esc = projectSavings(
        monthlyUsage: List.filled(12, 300),
        monthlyGenerationYear1: List.filled(12, 300),
        tariff: simpleTariff,
        exportRate: 2,
        escalationPctPerYear: 3,
        degradationPctPerYear: 0,
        years: 2,
        netPrice: 100000,
      );
      expect(esc.years[1].saving, closeTo(20400 * 1.03, 1e-6));

      final deg = projectSavings(
        monthlyUsage: List.filled(12, 300),
        monthlyGenerationYear1: List.filled(12, 300),
        tariff: simpleTariff,
        exportRate: 2,
        escalationPctPerYear: 0,
        degradationPctPerYear: 0.5,
        years: 2,
        netPrice: 100000,
      );
      expect(deg.years[1].saving, lessThan(20400));
    });

    test('payback interpolates within the year', () {
      final r = projectSavings(
        monthlyUsage: List.filled(12, 300),
        monthlyGenerationYear1: List.filled(12, 300),
        tariff: simpleTariff,
        exportRate: 2,
        escalationPctPerYear: 0,
        degradationPctPerYear: 0,
        years: 25,
        netPrice: 30600,
      );
      expect(r.paybackYears, closeTo(1.5, 1e-9));
    });

    test('never pays back → null; free system → 0', () {
      final never = projectSavings(
        monthlyUsage: List.filled(12, 10),
        monthlyGenerationYear1: List.filled(12, 10),
        tariff: simpleTariff,
        exportRate: 0,
        escalationPctPerYear: 0,
        degradationPctPerYear: 0,
        years: 2,
        netPrice: 1e9,
      );
      expect(never.paybackYears, isNull);

      final free = projectSavings(
        monthlyUsage: List.filled(12, 10),
        monthlyGenerationYear1: List.filled(12, 10),
        tariff: simpleTariff,
        exportRate: 0,
        escalationPctPerYear: 0,
        degradationPctPerYear: 0,
        years: 1,
        netPrice: 0,
      );
      expect(free.paybackYears, 0);
    });

    test('empty projection', () {
      final r = projectSavings(
        monthlyUsage: List.filled(12, 1),
        monthlyGenerationYear1: List.filled(12, 1),
        tariff: simpleTariff,
        exportRate: 0,
        escalationPctPerYear: 0,
        degradationPctPerYear: 0,
        years: 0,
        netPrice: 1,
      );
      expect(r.annualSavingYear1, 0);
      expect(r.lifetimeSaving, 0);
    });

    test('rejects missing months', () {
      expect(
        () => projectSavings(
          monthlyUsage: const [1],
          monthlyGenerationYear1: List.filled(12, 1),
          tariff: simpleTariff,
          exportRate: 0,
          escalationPctPerYear: 0,
          degradationPctPerYear: 0,
          years: 1,
          netPrice: 1,
        ),
        throwsArgumentError,
      );
    });

    test('usage profile uses full history, else repeats the average', () {
      final h = List<double>.generate(12, (i) => i * 10.0);
      expect(usageProfile(avgMonthlyUnits: 5, history: h), h);
      expect(
        usageProfile(avgMonthlyUnits: 5, history: const [1, 2]),
        List.filled(12, 5),
      );
      expect(usageProfile(avgMonthlyUnits: 5), List.filled(12, 5));
    });
  });

  group('SolarConfig.fromMap', () {
    final values = <String, Object?>{
      'sqm_per_kw': 10,
      'default_yield_kwh_per_kw_day': 4.2,
      'shading_loss_pct': {'none': 0, 'low': 3, 'medium': 8, 'high': 15},
      'degradation_pct': 0.5,
      'tariff_escalation_pct': 3,
      'export_rate_per_kwh': 2,
      'lifetime_years': 25,
      'default_price_per_kw': 60000,
    };

    test('reads every key', () {
      final c = SolarConfig.fromMap(values);
      expect(c.sqmPerKw, 10);
      expect(c.defaultYieldKwhPerKwDay, 4.2);
      expect(c.shadingLossPct[ShadingLevel.high], 15);
      expect(c.lifetimeYears, 25);
      expect(c.pricePerKw, 60000);
    });

    test('names the missing key', () {
      expect(
        () => SolarConfig.fromMap({...values}..remove('sqm_per_kw')),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('sqm_per_kw'),
          ),
        ),
      );
      expect(
        () => SolarConfig.fromMap({...values}..remove('shading_loss_pct')),
        throwsFormatException,
      );
    });
  });
}
