import 'package:solar_core/solar_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  final perKw = fallbackMonthlyPerKw(4.2);

  group('roundUpToHalfKw', () {
    test('rounds up to 0.5', () {
      expect(roundUpToHalfKw(2.0), 2.0);
      expect(roundUpToHalfKw(2.01), 2.5);
      expect(roundUpToHalfKw(2.5), 2.5);
      expect(roundUpToHalfKw(2.5000000001), 2.5);
      expect(roundUpToHalfKw(2.51), 3.0);
      expect(roundUpToHalfKw(0), 0);
      expect(roundUpToHalfKw(-1), 0);
    });
  });

  group('generation', () {
    test('fallback uses yield × days in month', () {
      expect(perKw, hasLength(12));
      expect(perKw[0], closeTo(130.2, 1e-9)); // Jan 31 days
      expect(perKw[1], closeTo(117.6, 1e-9)); // Feb 28 days
      expect(sum(perKw), closeTo(4.2 * 365, 1e-9));
    });

    test('scales by kW and applies shading', () {
      final none = monthlyGeneration(
        kw: 3,
        monthlyPerKw: perKw,
        shading: ShadingLevel.none,
        config: config,
      );
      final high = monthlyGeneration(
        kw: 3,
        monthlyPerKw: perKw,
        shading: ShadingLevel.high,
        config: config,
      );
      expect(sum(none), closeTo(4.2 * 365 * 3, 1e-6));
      expect(sum(high), closeTo(sum(none) * 0.85, 1e-6));
    });

    test('rejects anything but 12 months', () {
      expect(
        () => monthlyGeneration(
          kw: 1,
          monthlyPerKw: const [1, 2],
          shading: ShadingLevel.none,
          config: config,
        ),
        throwsArgumentError,
      );
    });

    test('degrades 0.5% per year', () {
      final y1 = List<double>.filled(12, 100);
      expect(degradedGeneration(y1, 1, 0.5).first, 100);
      expect(degradedGeneration(y1, 2, 0.5).first, closeTo(99.5, 1e-9));
      expect(degradedGeneration(y1, 3, 0.5).first, closeTo(99.0025, 1e-9));
    });
  });

  group('recommendSize', () {
    test('300 units/month → 2.5 kW, shows 2 and 3 kW too', () {
      final r = recommendSize(
        avgMonthlyUnits: 300,
        monthlyPerKw: perKw,
        sqmPerKw: 10,
      );
      expect(r.requiredKw, closeTo(300 / 127.75, 1e-9));
      expect(r.recommendedKw, 2.5);
      expect(r.options, [2.0, 2.5, 3.0]);
      expect(r.limitedByRoof, isFalse);
      expect(r.maxKwByRoof, isNull);
      expect(r.exceedsSanctionedLoad, isFalse);
    });

    test('roof area limits the size and hides options that do not fit', () {
      final r = recommendSize(
        avgMonthlyUnits: 300,
        monthlyPerKw: perKw,
        sqmPerKw: 10,
        usableAreaSqm: 15,
      );
      expect(r.maxKwByRoof, 1.5);
      expect(r.recommendedKw, 1.5);
      expect(r.limitedByRoof, isTrue);
      expect(r.options, [1.5]);
    });

    test('warns when above sanctioned load', () {
      final r = recommendSize(
        avgMonthlyUnits: 300,
        monthlyPerKw: perKw,
        sqmPerKw: 10,
        sanctionedLoadKw: 2,
      );
      expect(r.exceedsSanctionedLoad, isTrue);
      final ok = recommendSize(
        avgMonthlyUnits: 300,
        monthlyPerKw: perKw,
        sqmPerKw: 10,
        sanctionedLoadKw: 5,
      );
      expect(ok.exceedsSanctionedLoad, isFalse);
    });

    test('low usage does not push 2/3 kW options', () {
      final r = recommendSize(
        avgMonthlyUnits: 100,
        monthlyPerKw: perKw,
        sqmPerKw: 10,
      );
      expect(r.recommendedKw, 1.0);
      expect(r.options, [1.0]);
    });

    test('high usage keeps 2 and 3 kW alongside the recommendation', () {
      final r = recommendSize(
        avgMonthlyUnits: 900,
        monthlyPerKw: perKw,
        sqmPerKw: 10,
        usableAreaSqm: 100,
      );
      expect(r.recommendedKw, 7.5);
      expect(r.options, [2.0, 3.0, 7.5]);
    });

    test('zero usage recommends nothing', () {
      final r = recommendSize(
        avgMonthlyUnits: 0,
        monthlyPerKw: perKw,
        sqmPerKw: 10,
      );
      expect(r.recommendedKw, 0);
      expect(r.options, isEmpty);
    });

    test('rejects negative usage', () {
      expect(
        () => recommendSize(
          avgMonthlyUnits: -1,
          monthlyPerKw: perKw,
          sqmPerKw: 10,
        ),
        throwsArgumentError,
      );
    });

    test('zero yield does not divide by zero', () {
      final r = recommendSize(
        avgMonthlyUnits: 300,
        monthlyPerKw: List.filled(12, 0),
        sqmPerKw: 10,
      );
      expect(r.requiredKw, 0);
    });

    test('clampKw', () {
      expect(clampKw(0.1), 0.5);
      expect(clampKw(20), 10);
      expect(clampKw(3), 3);
    });
  });
}
