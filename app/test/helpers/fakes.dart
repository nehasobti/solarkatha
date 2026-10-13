import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solarkatha/features/admin/data/admin_repository.dart';
import 'package:solarkatha/features/projects/data/projects_repository.dart';
import 'package:solarkatha/features/tracking/presentation/tracking_screen.dart';
import 'package:solarkatha/app.dart';
import 'package:solarkatha/core/preferences/app_preferences.dart';
import 'package:solarkatha/data/models/company.dart';
import 'package:solarkatha/data/models/profile.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/data/powersync/powersync_providers.dart';
import 'package:solarkatha/data/repositories/auth_repository.dart';
import 'package:solarkatha/data/repositories/profile_repository.dart';
import 'package:solarkatha/features/auth/application/app_session.dart';
import 'package:solarkatha/features/auth/application/session_controller.dart';
import 'package:solarkatha/features/bills/application/scan_processor.dart';
import 'package:solarkatha/features/bills/data/bills_repository.dart';
import 'package:solarkatha/features/leads/data/leads_repository.dart';
import 'package:solarkatha/features/proposals/data/proposals_repository.dart';
import 'package:solarkatha/features/sizing/data/sizing_repository.dart';
import 'package:solarkatha/features/assistant/data/assistant_api.dart';
import 'package:solarkatha/features/survey/data/maps_api.dart';
import 'package:solarkatha/features/survey/data/survey_repository.dart';
import 'package:solarkatha/features/survey/presentation/survey_screen.dart';

import 'fake_projects.dart';
import 'fake_bills.dart';
import 'fake_proposals.dart';
import 'fake_survey.dart';
import 'fake_leads_repository.dart';

export 'fake_bills.dart';
export 'fake_projects.dart';
export 'fake_proposals.dart';
export 'fake_survey.dart';
export 'fake_leads_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

/// Sync does nothing in widget tests.
class FakeSyncController extends SyncController {
  @override
  void build() {}
}

class FakeSessionController extends SessionController {
  FakeSessionController(this._session);

  final AppSession _session;

  @override
  Future<AppSession> build() async => _session;

  @override
  Future<void> signOut() async => state = const AsyncData(SignedOut());
}

const demoCompany = Company(
  id: 'c1',
  name: 'Demo Solar Solutions',
  stateCode: 'UP',
);

Ready readyAs(UserRole role, {String language = 'en'}) => Ready(
  profile: Profile(
    id: 'u-${role.name}',
    companyId: demoCompany.id,
    name: 'Test ${role.name}',
    phone: '919999900001',
    role: role,
    language: language,
  ),
  company: demoCompany,
);

/// Pumps the full app with a fixed session and language.
Future<void> pumpApp(
  WidgetTester tester, {
  required AppSession session,
  String language = 'en',
  Size size = const Size(400, 800),
  AuthRepository? auth,
  FakeLeadsRepository? leads,
  FakeBillsRepository? bills,
  FakeProposalsRepository? proposals,
  FakeSurveyRepository? survey,
  FakeProjectsRepository? projects,
  FakeAdminRepository? admin,
  FakeTrackingApi? tracking,
  FakeMapsApi? maps,
  FakeAssistantApi? assistant,
  bool highContrast = false,
  bool largeText = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'pref.language': language,
    'pref.highContrast': highContrast,
    'pref.largeText': largeText,
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionControllerProvider.overrideWith(
          () => FakeSessionController(session),
        ),
        authRepositoryProvider.overrideWithValue(auth ?? MockAuthRepository()),
        profileRepositoryProvider.overrideWithValue(MockProfileRepository()),
        leadsRepositoryProvider.overrideWithValue(
          leads ?? FakeLeadsRepository(),
        ),
        syncControllerProvider.overrideWith(FakeSyncController.new),
        syncStatusProvider.overrideWith((ref) => const Stream.empty()),
        billsRepositoryProvider.overrideWithValue(
          bills ?? FakeBillsRepository(),
        ),
        scanProcessorProvider.overrideWith(FakeScanProcessor.new),
        sizingConfigProvider.overrideWith(
          (ref) => Stream.value(seededSizingConfig()),
        ),
        generationServiceProvider.overrideWithValue(FakeGenerationService()),
        proposalsRepositoryProvider.overrideWithValue(
          proposals ?? FakeProposalsRepository(),
        ),
        surveyRepositoryProvider.overrideWithValue(
          survey ?? FakeSurveyRepository(),
        ),
        satelliteTilesProvider.overrideWithValue(false),
        projectsRepositoryProvider.overrideWithValue(
          projects ?? FakeProjectsRepository(),
        ),
        adminRepositoryProvider.overrideWithValue(
          admin ?? FakeAdminRepository(),
        ),
        mapsApiProvider.overrideWithValue(maps ?? FakeMapsApi()),
        assistantApiProvider.overrideWithValue(assistant ?? FakeAssistantApi()),
        trackingApiProvider.overrideWithValue(
          tracking ?? FakeTrackingApi(null),
        ),
      ],
      child: const SolarKathaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

class FakeAssistantApi extends Mock implements AssistantApi {
  final asked = <List<ChatTurn>>[];

  @override
  Future<String> ask(List<ChatTurn> turns, String lang) async {
    asked.add([...turns]);
    return 'SolarKatha helps rooftop solar installers.';
  }
}
