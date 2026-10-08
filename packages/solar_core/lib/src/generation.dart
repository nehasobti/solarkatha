import 'config.dart';

/// Days in each month of a non-leap year (Jan..Dec).
const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/// Monthly kWh per kW when PVGIS is not available: a flat daily yield times
/// the days in each month.
List<double> fallbackMonthlyPerKw(double yieldKwhPerKwDay) => [
  for (final d in daysInMonth) yieldKwhPerKwDay * d,
];

/// Monthly generation (kWh) for [kw] given per-kW monthly yield and the
/// shading loss for [shading].
List<double> monthlyGeneration({
  required double kw,
  required List<double> monthlyPerKw,
  required ShadingLevel shading,
  required SolarConfig config,
}) {
  _checkTwelve(monthlyPerKw, 'monthlyPerKw');
  final factor = 1 - (config.shadingLossPct[shading] ?? 0) / 100;
  return [for (final m in monthlyPerKw) m * kw * factor];
}

/// Generation in year [year] (1-based) after yearly degradation.
List<double> degradedGeneration(
  List<double> yearOne,
  int year,
  double degradationPctPerYear,
) {
  final factor = _pow(1 - degradationPctPerYear / 100, year - 1);
  return [for (final m in yearOne) m * factor];
}

double sum(Iterable<double> values) => values.fold(0, (a, b) => a + b);

double _pow(double base, int exp) {
  var r = 1.0;
  for (var i = 0; i < exp; i++) {
    r *= base;
  }
  return r;
}

void _checkTwelve(List<double> values, String name) {
  if (values.length != 12) {
    throw ArgumentError.value(values.length, name, 'must have 12 months');
  }
}
