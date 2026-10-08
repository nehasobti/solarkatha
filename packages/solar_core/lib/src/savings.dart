import 'dart:math' as math;

import 'generation.dart';
import 'tariff.dart';

class YearSaving {
  const YearSaving({
    required this.year,
    required this.saving,
    required this.cumulative,
  });

  final int year;
  final double saving;
  final double cumulative;
}

class SavingsResult {
  const SavingsResult({
    required this.years,
    required this.netPrice,
    required this.paybackYears,
  });

  final List<YearSaving> years;
  final double netPrice;

  /// Years until cumulative savings cover [netPrice], interpolated within
  /// the year. Null if it never pays back within the period.
  final double? paybackYears;

  double get annualSavingYear1 => years.isEmpty ? 0 : years.first.saving;
  double get monthlySavingYear1 => annualSavingYear1 / 12;
  double get lifetimeSaving => years.isEmpty ? 0 : years.last.cumulative;
}

/// Saving in one month: bill without solar minus bill with solar.
///
/// Simplified net metering: generation offsets the customer's own usage at
/// their tariff (so it can never save more than their own energy charge);
/// surplus is valued at [exportRate]. The fixed charge is unchanged.
double monthSaving({
  required double usage,
  required double generation,
  required Tariff tariff,
  required double exportRate,
  double rateMultiplier = 1,
}) {
  final before = tariff.energyCharge(usage, rateMultiplier: rateMultiplier);
  final after = tariff.energyCharge(
    math.max(0, usage - generation),
    rateMultiplier: rateMultiplier,
  );
  final surplus = math.max(0.0, generation - usage);
  return before - after + surplus * exportRate;
}

/// Year-by-year savings with tariff escalation and panel degradation, and
/// the payback period on [netPrice].
SavingsResult projectSavings({
  required List<double> monthlyUsage,
  required List<double> monthlyGenerationYear1,
  required Tariff tariff,
  required double exportRate,
  required double escalationPctPerYear,
  required double degradationPctPerYear,
  required int years,
  required double netPrice,
}) {
  if (monthlyUsage.length != 12 || monthlyGenerationYear1.length != 12) {
    throw ArgumentError('monthlyUsage and generation must have 12 months');
  }
  final out = <YearSaving>[];
  var cumulative = 0.0;
  double? payback;
  for (var y = 1; y <= years; y++) {
    final gen = degradedGeneration(
      monthlyGenerationYear1,
      y,
      degradationPctPerYear,
    );
    final multiplier = math
        .pow(1 + escalationPctPerYear / 100, y - 1)
        .toDouble();
    var saving = 0.0;
    for (var m = 0; m < 12; m++) {
      saving += monthSaving(
        usage: monthlyUsage[m],
        generation: gen[m],
        tariff: tariff,
        exportRate: exportRate,
        rateMultiplier: multiplier,
      );
    }
    final before = cumulative;
    cumulative += saving;
    if (payback == null &&
        netPrice > 0 &&
        cumulative >= netPrice &&
        saving > 0) {
      payback = (y - 1) + (netPrice - before) / saving;
    }
    out.add(YearSaving(year: y, saving: saving, cumulative: cumulative));
  }
  if (netPrice <= 0) payback = 0;
  return SavingsResult(years: out, netPrice: netPrice, paybackYears: payback);
}

/// Twelve months of usage from a bill: the printed history when complete,
/// otherwise the average repeated.
List<double> usageProfile({
  required double avgMonthlyUnits,
  List<double>? history,
}) {
  if (history != null && history.length == 12) return history;
  return List.filled(12, avgMonthlyUnits);
}
