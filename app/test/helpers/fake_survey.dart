import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:latlong2/latlong.dart';
import 'package:solarkatha/features/survey/data/maps_api.dart';
import 'package:solarkatha/features/survey/data/survey_repository.dart';
import 'package:solarkatha/features/survey/domain/roof_geometry.dart';
import 'package:solarkatha/features/survey/domain/site.dart';

/// Seeded app_config panel settings with a 540 Wp DCR panel.
const seededSurveyConfig = SurveyConfig(
  panelLengthM: 2.278,
  panelWidthM: 1.134,
  panelWattPeak: 540,
  panelGapM: 0.05,
  edgeSetbackM: 0.6,
  sqmPerKw: 10,
);

class FakeSurveyRepository extends Mock implements SurveyRepository {
  FakeSurveyRepository({this.site});

  Site? site;
  final saved = <SurveyInput>[];
  final located = <(String, double, double)>[];

  @override
  Future<void> setLeadLocation(String leadId, double lat, double lng) async =>
      located.add((leadId, lat, lng));
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<Site?> watchSite(String leadId) async* {
    yield site;
    yield* _changes.stream.map((_) => site);
  }

  @override
  Future<SurveyConfig?> loadConfig(String companyId) async =>
      seededSurveyConfig;

  @override
  Future<void> saveSurvey({
    required String leadId,
    required String companyId,
    required String userId,
    required SurveyInput input,
    Site? existing,
    Uint8List? layoutPng,
  }) async {
    saved.add(input);
    site = Site(
      id: 's1',
      leadId: leadId,
      roofType: input.roofType,
      roof: input.roof,
      usableAreaSqm: input.layout.areaSqm,
      fittedPanelCount: input.layout.panelCount,
      fittedKw: input.layout.fittedKw,
      maxKw: input.layout.roofLimitKw,
      shading: input.shading,
    );
    _changes.add(null);
  }
}

/// Google lookups without the network: one address, one place, and a roof
/// about 10 m x 8 m around wherever it is asked.
class FakeMapsApi extends Mock implements MapsApi {
  final geocoded = <String>[];
  final solarAt = <LatLng>[];

  @override
  Future<GeoHit?> geocode(String address) async {
    geocoded.add(address);
    return const GeoHit(LatLng(26.8524, 81.0202), 'Lucknow 226010');
  }

  @override
  Future<List<PlaceSuggestion>> autocomplete(
    String input,
    String session,
  ) async => const [
    PlaceSuggestion('p1', 'Hazratganj, Lucknow, Uttar Pradesh'),
  ];

  @override
  Future<GeoHit?> place(String placeId, String session) async =>
      const GeoHit(LatLng(26.8500, 80.9450), 'Hazratganj, Lucknow');

  @override
  Future<SolarInsights?> solar(LatLng at) async {
    solarAt.add(at);
    return SolarInsights(
      center: at,
      sw: LatLng(at.latitude - 0.000036, at.longitude - 0.00005),
      ne: LatLng(at.latitude + 0.000036, at.longitude + 0.00005),
      areaSqm: 80,
      maxPanels: 21,
      maxSunshineHours: 1760,
      imageryDate: '2025-02-10',
      segments: const [
        RoofSegmentInfo(
          pitchDeg: 2,
          azimuthDeg: 172,
          areaSqm: 80,
          sunshineMedian: 1500,
        ),
      ],
    );
  }
}
