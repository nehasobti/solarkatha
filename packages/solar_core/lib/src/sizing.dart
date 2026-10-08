import 'dart:math' as math;

import 'generation.dart';

/// Rounds up to the next 0.5 kW (2.1 → 2.5, 2.5 → 2.5).
double roundUpToHalfKw(double kw) {
  if (kw <= 0) return 0;
  // Small epsilon so 2.5000000001 from float maths doesn't become 3.0.
  return (kw * 2 - 1e-9).ceil() / 2;
}

class SizingResult {
  const SizingResult({
    required this.requiredKw,
    required this.recommendedKw,
    required this.maxKwByRoof,
    required this.limitedByRoof,
    required this.exceedsSanctionedLoad,
    required this.options,
  });

  /// Exact kW that would cover the average monthly usage.
  final double requiredKw;

  /// [requiredKw] rounded up to 0.5 kW, capped by the roof.
  final double recommendedKw;

  /// Largest system the roof allows (null when area is unknown).
  final double? maxKwByRoof;

  final bool limitedByRoof;

  /// Recommended size is above the sanctioned load: the customer may need a
  /// load increase.
  final bool exceedsSanctionedLoad;

  /// Sizes to show side by side: 2 kW and 3 kW when usage allows (3 kW reaches
  /// the full central subsidy), plus the recommendation. Sorted, unique.
  final List<double> options;
}

/// Recommends a system size.
///
/// Required kW = average monthly units ÷ average monthly generation per kW,
/// rounded up to 0.5 kW, limited by roof area ÷ `sqm_per_kw`.
SizingResult recommendSize({
  required double avgMonthlyUnits,
  required List<double> monthlyPerKw,
  required double sqmPerKw,
  double? sanctionedLoadKw,
  double? usableAreaSqm,
}) {
  if (avgMonthlyUnits < 0) {
    throw ArgumentError.value(avgMonthlyUnits, 'avgMonthlyUnits');
  }
  final perKwMonth = sum(monthlyPerKw) / monthlyPerKw.length;
  final required = perKwMonth <= 0 ? 0.0 : avgMonthlyUnits / perKwMonth;

  final maxByRoof = usableAreaSqm == null || usableAreaSqm <= 0
      ? null
      : (usableAreaSqm / sqmPerKw * 2).floor() / 2;

  var recommended = roundUpToHalfKw(required);
  var limited = false;
  if (maxByRoof != null && recommended > maxByRoof) {
    recommended = maxByRoof;
    limited = true;
  }

  final options = <double>{recommended};
  // Show 2 and 3 kW when usage justifies at least ~2 kW and the roof fits it.
  for (final kw in const [2.0, 3.0]) {
    final fits = maxByRoof == null || kw <= maxByRoof;
    if (fits && required >= 1.5) options.add(kw);
  }
  options.removeWhere((kw) => kw <= 0);

  return SizingResult(
    requiredKw: required,
    recommendedKw: recommended,
    maxKwByRoof: maxByRoof,
    limitedByRoof: limited,
    exceedsSanctionedLoad:
        sanctionedLoadKw != null &&
        sanctionedLoadKw > 0 &&
        recommended > sanctionedLoadKw,
    options: options.toList()..sort(),
  );
}

/// Clamp helper for UI sliders.
double clampKw(double kw, {double min = 0.5, double max = 10}) =>
    math.min(max, math.max(min, kw));
