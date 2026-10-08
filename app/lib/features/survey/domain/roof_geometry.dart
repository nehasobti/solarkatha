import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Survey settings. Seeded here; moves to `app_config` / the products table
/// once those exist (see DECISIONS.md).
class SurveyConfig {
  const SurveyConfig({
    this.panelLengthM = 2.278,
    this.panelWidthM = 1.134,
    this.panelWattPeak = 550,
    this.panelGapM = 0.05,
    this.edgeSetbackM = 0.6,
    this.sqmPerKw = 10,
    this.shadingLossPct = const {
      ShadingLevel.none: 0,
      ShadingLevel.low: 3,
      ShadingLevel.medium: 8,
      ShadingLevel.high: 15,
    },
  });

  final double panelLengthM;
  final double panelWidthM;
  final double panelWattPeak;
  final double panelGapM;
  final double edgeSetbackM;
  final double sqmPerKw;
  final Map<ShadingLevel, double> shadingLossPct;
}

enum ShadingLevel { none, low, medium, high }

/// A point in metres on a local flat plane around the roof.
typedef Xy = ({double x, double y});

/// Converts between lat/lng and a local metre grid. Accurate to centimetres
/// over a rooftop.
class LocalProjection {
  LocalProjection(this.origin)
    : _mPerDegLng = 111320 * math.cos(origin.latitude * math.pi / 180);

  final LatLng origin;
  static const _mPerDegLat = 110540.0;
  final double _mPerDegLng;

  Xy toXy(LatLng p) => (
    x: (p.longitude - origin.longitude) * _mPerDegLng,
    y: (p.latitude - origin.latitude) * _mPerDegLat,
  );

  LatLng toLatLng(Xy p) => LatLng(
    origin.latitude + p.y / _mPerDegLat,
    origin.longitude + p.x / _mPerDegLng,
  );
}

/// Area in m² of a simple polygon (shoelace formula).
double polygonAreaXy(List<Xy> pts) {
  var sum = 0.0;
  for (var i = 0; i < pts.length; i++) {
    final a = pts[i];
    final b = pts[(i + 1) % pts.length];
    sum += a.x * b.y - b.x * a.y;
  }
  return sum.abs() / 2;
}

double roofAreaSqm(List<LatLng> roof) {
  if (roof.length < 3) return 0;
  final proj = LocalProjection(roof.first);
  return polygonAreaXy(roof.map(proj.toXy).toList());
}

bool _pointInPolygon(Xy p, List<Xy> poly) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final a = poly[i];
    final b = poly[j];
    if ((a.y > p.y) != (b.y > p.y) &&
        p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x) {
      inside = !inside;
    }
  }
  return inside;
}

double _distToSegment(Xy p, Xy a, Xy b) {
  final dx = b.x - a.x;
  final dy = b.y - a.y;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : ((p.x - a.x) * dx + (p.y - a.y) * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final cx = a.x + t * dx - p.x;
  final cy = a.y + t * dy - p.y;
  return math.sqrt(cx * cx + cy * cy);
}

Xy _rotate(Xy p, double angle) {
  final c = math.cos(angle);
  final s = math.sin(angle);
  return (x: p.x * c - p.y * s, y: p.x * s + p.y * c);
}

/// Result of fitting panels onto a roof outline.
class PanelLayout {
  const PanelLayout({
    required this.areaSqm,
    required this.panels,
    required this.panelWattPeak,
    required this.sqmPerKw,
  });

  final double areaSqm;

  /// Each panel as four corners (lat/lng), for drawing.
  final List<List<LatLng>> panels;
  final double panelWattPeak;
  final double sqmPerKw;

  int get panelCount => panels.length;

  /// Capacity of the panels that physically fit.
  double get fittedKw => panelCount * panelWattPeak / 1000;

  /// Rule-of-thumb limit from area alone (`sqm_per_kw`).
  double get maxKwByArea => areaSqm / sqmPerKw;

  /// The roof limit used for sizing: the smaller of the two.
  double get roofLimitKw => math.min(fittedKw, maxKwByArea);
}

/// Fits panels in a grid aligned to the roof's longest edge, keeping
/// [SurveyConfig.edgeSetbackM] clear of every edge. Tries portrait and
/// landscape and several grid offsets, and keeps the best.
PanelLayout fitPanels(
  List<LatLng> roof, {
  SurveyConfig config = const SurveyConfig(),
}) {
  if (roof.length < 3) {
    return PanelLayout(
      areaSqm: 0,
      panels: const [],
      panelWattPeak: config.panelWattPeak,
      sqmPerKw: config.sqmPerKw,
    );
  }
  final proj = LocalProjection(roof.first);
  final poly = roof.map(proj.toXy).toList();
  final area = polygonAreaXy(poly);

  // Align the grid with the longest edge.
  var angle = 0.0;
  var longest = -1.0;
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i];
    final b = poly[(i + 1) % poly.length];
    final len = math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2));
    if (len > longest) {
      longest = len;
      angle = math.atan2(b.y - a.y, b.x - a.x);
    }
  }
  final aligned = poly.map((p) => _rotate(p, -angle)).toList();
  final minX = aligned.map((p) => p.x).reduce(math.min);
  final maxX = aligned.map((p) => p.x).reduce(math.max);
  final minY = aligned.map((p) => p.y).reduce(math.min);
  final maxY = aligned.map((p) => p.y).reduce(math.max);

  bool fits(List<Xy> corners) {
    for (final c in corners) {
      if (!_pointInPolygon(c, aligned)) return false;
      for (var i = 0; i < aligned.length; i++) {
        final d = _distToSegment(
          c,
          aligned[i],
          aligned[(i + 1) % aligned.length],
        );
        if (d < config.edgeSetbackM) return false;
      }
    }
    // Concave roofs: no roof corner may poke into the panel.
    final rx0 = corners[0].x, ry0 = corners[0].y;
    final rx1 = corners[2].x, ry1 = corners[2].y;
    for (final v in aligned) {
      if (v.x > rx0 && v.x < rx1 && v.y > ry0 && v.y < ry1) return false;
    }
    return true;
  }

  var best = <List<Xy>>[];
  for (final (w, h) in [
    (config.panelWidthM, config.panelLengthM),
    (config.panelLengthM, config.panelWidthM),
  ]) {
    final stepX = w + config.panelGapM;
    final stepY = h + config.panelGapM;
    for (var ox = 0.0; ox < stepX; ox += stepX / 4) {
      for (var oy = 0.0; oy < stepY; oy += stepY / 4) {
        final found = <List<Xy>>[];
        for (var y = minY + oy; y + h <= maxY; y += stepY) {
          for (var x = minX + ox; x + w <= maxX; x += stepX) {
            final corners = <Xy>[
              (x: x, y: y),
              (x: x + w, y: y),
              (x: x + w, y: y + h),
              (x: x, y: y + h),
            ];
            if (fits(corners)) found.add(corners);
          }
        }
        if (found.length > best.length) best = found;
      }
    }
  }

  return PanelLayout(
    areaSqm: area,
    panels: [
      for (final rect in best)
        [for (final c in rect) proj.toLatLng(_rotate(c, angle))],
    ],
    panelWattPeak: config.panelWattPeak,
    sqmPerKw: config.sqmPerKw,
  );
}
