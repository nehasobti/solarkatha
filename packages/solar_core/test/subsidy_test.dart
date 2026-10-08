import 'package:solar_core/solar_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('central subsidy (₹30k/kW for 2 kW, ₹18k for 3rd kW, cap ₹78k)', () {
    final cases = {
      1.0: 30000.0,
      2.0: 60000.0,
      2.5: 69000.0,
      3.0: 78000.0,
      5.0: 78000.0,
      10.0: 78000.0,
    };
    cases.forEach((kw, expected) {
      test('$kw kW → ₹$expected', () {
        final r = calculateSubsidy(
          kw: kw,
          central: centralRule,
          panelsEligible: true,
        );
        expect(r.central.amount, expected);
        expect(r.state.amount, 0);
        expect(r.total, expected);
      });
    });

    test('per-kW lines explain the cap', () {
      final r = applyRule(centralRule, 5);
      expect(r.lines, hasLength(2));
      expect(r.lines[0].fromKw, 0);
      expect(r.lines[0].toKw, 2);
      expect(r.lines[0].amount, 60000);
      expect(r.lines[1].fromKw, 2);
      expect(r.lines[1].toKw, 3);
      expect(r.lines[1].perKw, 18000);
      expect(r.capped, isFalse, reason: 'slabs already stop at 3 kW');
    });

    test('average per kW falls above 3 kW', () {
      final r3 = calculateSubsidy(
        kw: 3,
        central: centralRule,
        panelsEligible: true,
      );
      final r5 = calculateSubsidy(
        kw: 5,
        central: centralRule,
        panelsEligible: true,
      );
      expect(r3.perKw(3), 26000);
      expect(r5.perKw(5), 15600);
      expect(r5.perKw(0), 0);
    });

    test('zero or negative kW gives nothing', () {
      expect(applyRule(centralRule, 0).amount, 0);
      expect(applyRule(centralRule, -1).amount, 0);
    });
  });

  group('state top-up (UP: ₹15k/kW up to ₹30k)', () {
    test('1 kW', () {
      final r = calculateSubsidy(
        kw: 1,
        central: centralRule,
        state: upStateRule,
        panelsEligible: true,
      );
      expect(r.state.amount, 15000);
      expect(r.total, 45000);
    });

    test('3 kW is capped at ₹30k', () {
      final r = calculateSubsidy(
        kw: 3,
        central: centralRule,
        state: upStateRule,
        panelsEligible: true,
      );
      expect(r.state.amount, 30000);
      expect(r.state.capped, isTrue);
      expect(r.total, 108000);
    });
  });

  test('non-DCR / non-ALMM panels get ₹0 with eligible = false', () {
    final r = calculateSubsidy(
      kw: 3,
      central: centralRule,
      state: upStateRule,
      panelsEligible: false,
    );
    expect(r.eligible, isFalse);
    expect(r.total, 0);
    expect(r.central.lines, isEmpty);
  });

  test('a cap smaller than the slab total limits the amount', () {
    const rule = SubsidyRule(
      slabs: [SubsidySlab(uptoKw: null, perKw: 20000)],
      capAmount: 50000,
    );
    final r = applyRule(rule, 4);
    expect(r.amount, 50000);
    expect(r.capped, isTrue);
  });

  test('slabs parse from JSON', () {
    final slab = SubsidySlab.fromJson({'upto_kw': 2, 'per_kw': 30000});
    expect(slab.uptoKw, 2);
    expect(slab.perKw, 30000);
    expect(SubsidySlab.fromJson({'upto_kw': null, 'per_kw': 1}).uptoKw, isNull);
  });
}
