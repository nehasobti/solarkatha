import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:solar_core/solar_core.dart';

enum RoofType { rcc, tinSheet, other }

extension RoofTypeDb on RoofType {
  String get dbValue => switch (this) {
    RoofType.rcc => 'rcc',
    RoofType.tinSheet => 'tin_sheet',
    RoofType.other => 'other',
  };

  static RoofType? fromDb(Object? v) =>
      RoofType.values.where((t) => t.dbValue == v).firstOrNull;
}

double? _d(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

/// The roof survey of a lead (`public.sites`).
class Site {
  const Site({
    required this.id,
    required this.leadId,
    this.roofType,
    this.floors,
    this.roof = const [],
    this.usableAreaSqm,
    this.orientationDeg = 180,
    this.tiltDeg,
    this.shading = ShadingLevel.none,
    this.fittedPanelCount,
    this.fittedKw,
    this.maxKw,
    this.layoutPhotoId,
    this.notes,
    this.updatedAt,
  });

  final String id;
  final String leadId;
  final RoofType? roofType;
  final int? floors;

  /// Roof outline (first polygon).
  final List<LatLng> roof;
  final double? usableAreaSqm;
  final int orientationDeg;
  final int? tiltDeg;
  final ShadingLevel shading;
  final int? fittedPanelCount;
  final double? fittedKw;

  /// Largest system the roof allows (smaller of panels that fit and
  /// area ÷ m² per kW).
  final double? maxKw;
  final String? layoutPhotoId;
  final String? notes;
  final DateTime? updatedAt;

  factory Site.fromRow(Map<String, Object?> r) => Site(
    id: r['id']! as String,
    leadId: r['lead_id']! as String,
    roofType: RoofTypeDb.fromDb(r['roof_type']),
    floors: (r['floors'] as num?)?.toInt(),
    roof: polygonFromGeoJson(r['roof_polygons']),
    usableAreaSqm: _d(r['usable_area_sqm']),
    orientationDeg: (r['orientation_deg'] as num?)?.toInt() ?? 180,
    tiltDeg: (r['tilt_deg'] as num?)?.toInt(),
    shading:
        ShadingLevel.values
            .where((s) => s.name == r['shading_level'])
            .firstOrNull ??
        ShadingLevel.none,
    fittedPanelCount: (r['fitted_panel_count'] as num?)?.toInt(),
    fittedKw: _d(r['fitted_kw']),
    maxKw: _d(r['max_kw']),
    layoutPhotoId: r['layout_photo_id'] as String?,
    notes: r['notes'] as String?,
    updatedAt: DateTime.tryParse((r['updated_at'] as String?) ?? ''),
  );
}

/// GeoJSON FeatureCollection with one Polygon ([lng, lat], closed ring).
String polygonToGeoJson(List<LatLng> roof) => jsonEncode({
  'type': 'FeatureCollection',
  'features': [
    if (roof.length >= 3)
      {
        'type': 'Feature',
        'properties': {'kind': 'roof'},
        'geometry': {
          'type': 'Polygon',
          'coordinates': [
            [
              for (final p in [...roof, roof.first]) [p.longitude, p.latitude],
            ],
          ],
        },
      },
  ],
});

/// First polygon's outer ring, without the closing point.
List<LatLng> polygonFromGeoJson(Object? raw) {
  try {
    final j = raw is String ? jsonDecode(raw) : raw;
    final ring =
        (((j as Map)['features'] as List).first
                as Map)['geometry']['coordinates'][0]
            as List;
    final pts = [
      for (final c in ring)
        LatLng(((c as List)[1] as num).toDouble(), (c[0] as num).toDouble()),
    ];
    if (pts.length > 1 && pts.first == pts.last) pts.removeLast();
    return pts;
  } catch (_) {
    return const [];
  }
}

/// Compass label key for an azimuth (0 = north, 90 = east, 180 = south).
String compassPoint(int deg) {
  const names = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return names[((deg % 360) / 45).round() % 8];
}
