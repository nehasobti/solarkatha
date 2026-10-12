import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solarkatha/data/models/user_role.dart';

import '../helpers/fakes.dart';

/// Phase 1 definition of done: each role lands on its own empty screens, in
/// both languages, on phone and wide (web) layouts.
void main() {
  const phone = Size(360, 760);
  const wide = Size(1280, 800);

  group('English', () {
    testWidgets('owner on web sees the dashboard with all sections', (
      tester,
    ) async {
      await pumpApp(tester, session: readyAs(UserRole.owner), size: wide);
      expect(find.text('Leads this month'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      for (final label in [
        'Subsidy tracker',
        'Team',
        'Products',
        'Config',
        'Branding',
      ]) {
        // In the rail and in the dashboard shortcuts.
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(find.text('₹0'), findsOneWidget);
    });

    testWidgets('owner on phone gets a compact bottom bar', (tester) async {
      await pumpApp(tester, session: readyAs(UserRole.owner), size: phone);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Branding'), findsNothing);
    });

    testWidgets('sales rep sees home, leads and settings only', (tester) async {
      await pumpApp(tester, session: readyAs(UserRole.sales), size: phone);
      expect(find.text('Namaste, Test sales'), findsOneWidget);
      expect(find.text('New lead'), findsOneWidget);
      expect(find.text('Leads'), findsOneWidget);
      expect(find.text('Overview'), findsNothing);
      expect(find.text('Projects'), findsNothing);

      await tester.tap(find.text('Leads'));
      await tester.pumpAndSettle();
      expect(find.text('No leads yet'), findsOneWidget);
    });

    testWidgets('installer lands on projects', (tester) async {
      await pumpApp(tester, session: readyAs(UserRole.installer), size: phone);
      expect(find.text('No projects yet'), findsOneWidget);
      expect(find.text('Leads'), findsNothing);
    });

    testWidgets('settings shows the profile and signs out', (tester) async {
      await pumpApp(tester, session: readyAs(UserRole.sales), size: phone);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Test sales'), findsOneWidget);
      expect(find.text('Demo Solar Solutions'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('settings.signOut')),
        200,
      );
      await tester.tap(find.byKey(const Key('settings.signOut')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login.password')), findsOneWidget);
    });
  });

  group('Hindi', () {
    testWidgets('owner dashboard', (tester) async {
      await pumpApp(
        tester,
        session: readyAs(UserRole.owner, language: 'hi'),
        language: 'hi',
        size: wide,
      );
      expect(find.text('इस महीने की लीड'), findsOneWidget);
      expect(find.text('सब्सिडी ट्रैकर'), findsWidgets);
    });

    testWidgets('sales home', (tester) async {
      await pumpApp(
        tester,
        session: readyAs(UserRole.sales, language: 'hi'),
        language: 'hi',
        size: phone,
      );
      expect(find.text('नमस्ते, Test sales'), findsOneWidget);
      expect(find.text('नई लीड'), findsOneWidget);
      expect(find.text('आज कोई फ़ॉलो-अप नहीं'), findsOneWidget);
    });

    testWidgets('installer projects', (tester) async {
      await pumpApp(
        tester,
        session: readyAs(UserRole.installer, language: 'hi'),
        language: 'hi',
        size: phone,
      );
      expect(find.text('अभी कोई प्रोजेक्ट नहीं'), findsOneWidget);
    });
  });

  testWidgets('profile language is applied on sign-in', (tester) async {
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales, language: 'hi'),
      size: phone,
    );
    expect(find.text('नई लीड'), findsOneWidget);
  });

  group('accessibility', () {
    Future<void> outdoor(WidgetTester tester, UserRole role) async {
      await pumpApp(
        tester,
        session: readyAs(role),
        size: const Size(360, 640),
        highContrast: true,
        largeText: true,
      );
      expect(tester.takeException(), isNull);
    }

    testWidgets(
      'owner dashboard: 360 dp, high contrast, large text',
      (tester) => outdoor(tester, UserRole.owner),
    );
    testWidgets(
      'sales home: 360 dp, high contrast, large text',
      (tester) => outdoor(tester, UserRole.sales),
    );
  });
}
