import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/supabase_providers.dart';

part 'maps_api.g.dart';

class PlaceSuggestion {
  const PlaceSuggestion(this.placeId, this.text);

  final String placeId;
  final String text;
}

class GeoHit {
  const GeoHit(this.point, this.address);

  final LatLng point;
  final String address;
}

class RoofSegmentInfo {
  const RoofSegmentInfo({
    required this.pitchDeg,
    required this.azimuthDeg,
    required this.areaSqm,
    this.sunshineMedian,
  });

  final double pitchDeg;
  final double azimuthDeg;
  final double areaSqm;
  final double? sunshineMedian;
}

/// Google Solar API building insights, trimmed by the `maps` function.
class SolarInsights {
  const SolarInsights({
    required this.center,
    this.sw,
    this.ne,
    this.areaSqm,
    this.maxPanels,
    this.panelWatts,
    this.maxSunshineHours,
    this.imageryDate,
    this.segments = const [],
  });

  final LatLng center;
  final LatLng? sw;
  final LatLng? ne;
  final double? areaSqm;
  final int? maxPanels;
  final double? panelWatts;
  final double? maxSunshineHours;
  final String? imageryDate;
  final List<RoofSegmentInfo> segments;

  /// The building's bounding box as four corners (SW, SE, NE, NW).
  List<LatLng>? get outline => sw == null || ne == null
      ? null
      : [
          sw!,
          LatLng(sw!.latitude, ne!.longitude),
          ne!,
          LatLng(ne!.latitude, sw!.longitude),
        ];

  /// Main roof direction, rounded to the survey slider's 15° steps.
  int? get orientationDeg => segments.isEmpty
      ? null
      : ((segments.first.azimuthDeg / 15).round() * 15) % 360;

  /// Shade estimate: how far the roof's median sunshine falls below the best
  /// spot on it.
  String? get shading {
    final best = maxSunshineHours;
    final median = segments.isEmpty ? null : segments.first.sunshineMedian;
    if (best == null || median == null || best <= 0) return null;
    final r = median / best;
    return r >= 0.9
        ? 'none'
        : r >= 0.8
        ? 'low'
        : r >= 0.65
        ? 'medium'
        : 'high';
  }

  static LatLng? _ll(Object? v) {
    if (v is! Map) return null;
    final lat = (v['lat'] as num?)?.toDouble();
    final lng = (v['lng'] as num?)?.toDouble();
    return lat == null || lng == null ? null : LatLng(lat, lng);
  }

  static SolarInsights? fromJson(Map<String, dynamic> j) {
    final center = _ll(j['center']);
    if (center == null) return null;
    final box = j['box'];
    return SolarInsights(
      center: center,
      sw: box is Map ? _ll(box['sw']) : null,
      ne: box is Map ? _ll(box['ne']) : null,
      areaSqm: (j['areaSqm'] as num?)?.toDouble(),
      maxPanels: (j['maxPanels'] as num?)?.toInt(),
      panelWatts: (j['panelWatts'] as num?)?.toDouble(),
      maxSunshineHours: (j['maxSunshineHours'] as num?)?.toDouble(),
      imageryDate: j['imageryDate'] as String?,
      segments: [
        for (final s
            in (j['segments'] as List? ?? const [])
                .whereType<Map<dynamic, dynamic>>())
          RoofSegmentInfo(
            pitchDeg: (s['pitchDeg'] as num?)?.toDouble() ?? 0,
            azimuthDeg: (s['azimuthDeg'] as num?)?.toDouble() ?? 180,
            areaSqm: (s['areaSqm'] as num?)?.toDouble() ?? 0,
            sunshineMedian: (s['sunshineMedian'] as num?)?.toDouble(),
          ),
      ],
    );
  }
}

/// Address lookup, search and roof detection through the `maps` Edge
/// Function (the Google key stays on the server). Needs a connection.
class MapsApi {
  MapsApi(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final res = await _client.functions.invoke('maps', body: body);
    final data = res.data;
    return data is Map ? data.cast<String, dynamic>() : const {};
  }

  static GeoHit? _hit(Map<String, dynamic> j) {
    final lat = (j['lat'] as num?)?.toDouble();
    final lng = (j['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return GeoHit(LatLng(lat, lng), (j['address'] as String?) ?? '');
  }

  Future<GeoHit?> geocode(String address) async =>
      _hit(await _call({'action': 'geocode', 'address': address}));

  Future<List<PlaceSuggestion>> autocomplete(
    String input,
    String session,
  ) async {
    final j = await _call({
      'action': 'autocomplete',
      'input': input,
      'session': session,
    });
    return [
      for (final s
          in (j['suggestions'] as List? ?? const [])
              .whereType<Map<dynamic, dynamic>>())
        PlaceSuggestion(s['placeId'] as String, s['text'] as String? ?? ''),
    ];
  }

  Future<GeoHit?> place(String placeId, String session) async => _hit(
    await _call({'action': 'place', 'placeId': placeId, 'session': session}),
  );

  Future<SolarInsights?> solar(LatLng at) async => SolarInsights.fromJson(
    await _call({'action': 'solar', 'lat': at.latitude, 'lng': at.longitude}),
  );
}

@Riverpod(keepAlive: true)
MapsApi mapsApi(Ref ref) => MapsApi(ref.watch(supabaseClientProvider));
