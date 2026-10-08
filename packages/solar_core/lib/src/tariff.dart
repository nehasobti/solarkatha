import 'dart:math' as math;

/// One telescopic slab: [rate] ₹/kWh for units up to [uptoUnits] per month
/// (cumulative). A null [uptoUnits] means "all remaining units".
class TariffSlab {
  const TariffSlab({required this.uptoUnits, required this.rate});

  final double? uptoUnits;
  final double rate;

  factory TariffSlab.fromJson(Map<String, Object?> json) => TariffSlab(
    uptoUnits: (json['upto_units'] as num?)?.toDouble(),
    rate: (json['rate'] as num).toDouble(),
  );
}

/// A row of `tariffs` (simplified: energy slabs + fixed charge).
class Tariff {
  const Tariff({required this.slabs, this.fixedCharge = 0});

  final List<TariffSlab> slabs;

  /// Monthly fixed charge (₹), unaffected by solar.
  final double fixedCharge;

  /// Energy charge for [units] in one month, using telescopic slabs.
  double energyCharge(double units, {double rateMultiplier = 1}) {
    if (units <= 0) return 0;
    var from = 0.0;
    var total = 0.0;
    for (final slab in slabs) {
      if (from >= units) break;
      final to = math.min(units, slab.uptoUnits ?? double.infinity);
      if (to <= from) continue;
      total += (to - from) * slab.rate * rateMultiplier;
      from = to;
    }
    // Units beyond the last bounded slab are charged at the last rate.
    if (from < units && slabs.isNotEmpty) {
      total += (units - from) * slabs.last.rate * rateMultiplier;
    }
    return total;
  }

  /// Full monthly bill for [units].
  double monthlyBill(double units) => fixedCharge + energyCharge(units);

  /// Effective average ₹/kWh at [units].
  double averageRate(double units) =>
      units <= 0 ? 0 : energyCharge(units) / units;
}
