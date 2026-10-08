/// Shading level recorded during the survey.
enum ShadingLevel { none, low, medium, high }

/// Values from the `app_config` table that the calculations need.
class SolarConfig {
  const SolarConfig({
    required this.sqmPerKw,
    required this.defaultYieldKwhPerKwDay,
    required this.shadingLossPct,
    required this.degradationPctPerYear,
    required this.tariffEscalationPctPerYear,
    required this.exportRatePerKwh,
    required this.lifetimeYears,
    required this.pricePerKw,
  });

  /// Roof area needed per kW (m²).
  final double sqmPerKw;

  /// Fallback generation when PVGIS is unavailable (kWh per kW per day).
  final double defaultYieldKwhPerKwDay;

  /// Generation loss per shading level, in percent.
  final Map<ShadingLevel, double> shadingLossPct;

  final double degradationPctPerYear;
  final double tariffEscalationPctPerYear;

  /// Value of surplus units exported to the grid (₹/kWh).
  final double exportRatePerKwh;

  /// Years for the long-term savings view (25).
  final int lifetimeYears;

  /// Default turnkey price per kW (₹), used until products are priced.
  final double pricePerKw;

  /// Builds the config from `app_config` rows (key → decoded JSON value).
  /// Throws [FormatException] naming the first missing or invalid key.
  factory SolarConfig.fromMap(Map<String, Object?> values) {
    double number(String key) {
      final v = values[key];
      if (v is num) return v.toDouble();
      throw FormatException('app_config "$key" is missing or not a number');
    }

    final shading = values['shading_loss_pct'];
    if (shading is! Map) {
      throw const FormatException('app_config "shading_loss_pct" is missing');
    }
    return SolarConfig(
      sqmPerKw: number('sqm_per_kw'),
      defaultYieldKwhPerKwDay: number('default_yield_kwh_per_kw_day'),
      shadingLossPct: {
        for (final level in ShadingLevel.values)
          level: (shading[level.name] as num?)?.toDouble() ?? 0,
      },
      degradationPctPerYear: number('degradation_pct'),
      tariffEscalationPctPerYear: number('tariff_escalation_pct'),
      exportRatePerKwh: number('export_rate_per_kwh'),
      lifetimeYears: number('lifetime_years').round(),
      pricePerKw: number('default_price_per_kw'),
    );
  }
}
