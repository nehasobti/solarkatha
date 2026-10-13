import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solarkatha/core/l10n/l10n.dart';
import 'package:solarkatha/core/preferences/app_preferences.dart';
import 'package:solarkatha/core/theme/app_theme.dart';
import 'package:solarkatha/features/landing/data/landing_repository.dart';
import 'package:solarkatha/features/landing/presentation/landing_screen.dart';
import 'package:solarkatha/features/sizing/domain/sizing_config.dart';

import '../helpers/fakes.dart';

class FakeLandingRepository extends Mock implements LandingRepository {
  @override
  Future<SizingConfig> sizingDefaults() async => seededSizingConfig();

  @override
  Future<List<NewsItem>> latestNews(String lang, {int limit = 9}) async => [
    NewsItem(
      title: 'PM Surya Ghar crosses 20 lakh homes',
      url: 'https://news.example/1',
      source: 'The Hindu',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}

Future<void> pumpLanding(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        landingRepositoryProvider.overrideWithValue(FakeLandingRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LandingScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('landing shows pitch, calculator result and news', (
    tester,
  ) async {
    await pumpLanding(tester, const Size(1280, 900));
    expect(find.textContaining('Sell rooftop solar faster'), findsOneWidget);
    expect(find.text('Request access'), findsOneWidget);
    expect(find.byKey(const Key('assistant.open')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Recommended system'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    // 300 units a month in UP: 2.5 kW and the central + state subsidy.
    expect(find.text('2.5 kW'), findsOneWidget);
    expect(find.text('Government subsidy'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('calc.units')), '10');
    await tester.pumpAndSettle();
    expect(find.text('Enter at least 30 units a month.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('PM Surya Ghar crosses 20 lakh homes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('The Hindu · 2 days ago'), findsOneWidget);
  });

  testWidgets('landing fits a 360 dp phone', (tester) async {
    await pumpLanding(tester, const Size(360, 780));
    expect(tester.takeException(), isNull);
    expect(find.text('Request access'), findsOneWidget);
  });
}
