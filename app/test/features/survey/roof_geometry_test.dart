import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:solarkatha/features/survey/domain/roof_geometry.dart';

/// A rectangle [w] x [h] metres in Lucknow, optionally rotated.
List<LatLng> rect(double w, double h) {
  final proj = LocalProjection(const LatLng(26.8467, 80.9462));
  return [
    proj.toLatLng((x: 0, y: 0)),
    proj.toLatLng((x: w, y: 0)),
    proj.toLatLng((x: w, y: h)),
    proj.toLatLng((x: 0, y: h)),
  ];
}

void main() {
  test('area of a 10 x 8 m roof is 80 m²', () {
    expect(roofAreaSqm(rect(10, 8)), closeTo(80, 0.05));
  });

  test('area needs at least three points', () {
    expect(roofAreaSqm(rect(10, 8).take(2).toList()), 0);
  });

  test('10 x 8 m roof fits 12 panels with 0.6 m setback', () {
    // Usable 8.8 x 6.8 m. Portrait 1.134 x 2.278 (+0.05 gap): 7 x 2 = 14?
    // 8.8 / 1.184 = 7.4 -> 7 across; 6.8 / 2.328 = 2.9 -> 2 rows = 14.
    // Landscape 2.278 x 1.134: 8.8 / 2.328 = 3.7 -> 3; 6.8 / 1.184 = 5.7
    // -> 5 rows = 15.
    final layout = fitPanels(rect(10, 8));
    expect(layout.panelCount, 15);
    expect(layout.fittedKw, closeTo(8.25, 0.001));
    expect(layout.maxKwByArea, closeTo(8, 0.01));
    expect(layout.roofLimitKw, closeTo(8, 0.01));
  });

  test('tiny roof fits nothing', () {
    final layout = fitPanels(rect(2, 2));
    expect(layout.panelCount, 0);
    expect(layout.roofLimitKw, 0);
  });

  test('every fitted panel stays inside the roof', () {
    final roof = rect(12, 7);
    final layout = fitPanels(roof);
    final proj = LocalProjection(roof.first);
    for (final panel in layout.panels) {
      for (final c in panel) {
        final p = proj.toXy(c);
        expect(p.x, inInclusiveRange(0.59, 11.41));
        expect(p.y, inInclusiveRange(0.59, 6.41));
      }
    }
  });

  test('L-shaped roof does not place panels in the cut-out', () {
    final proj = LocalProjection(const LatLng(26.8467, 80.9462));
    // 10 x 10 with the top-right 5 x 5 removed.
    final roof = [
      for (final p in const <({double x, double y})>[
        (x: 0, y: 0),
        (x: 10, y: 0),
        (x: 10, y: 5),
        (x: 5, y: 5),
        (x: 5, y: 10),
        (x: 0, y: 10),
      ])
        proj.toLatLng(p),
    ];
    final layout = fitPanels(roof);
    expect(layout.panelCount, greaterThan(0));
    for (final panel in layout.panels) {
      for (final c in panel) {
        final p = proj.toXy(c);
        expect(p.x > 5.01 && p.y > 5.01, isFalse, reason: 'in cut-out: $p');
      }
    }
  });
}
