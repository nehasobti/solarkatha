import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
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
