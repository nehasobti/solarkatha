import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:solarkatha/core/router/routes.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/features/bills/domain/bill.dart';
import 'package:solarkatha/features/survey/domain/site.dart';

import '../../helpers/fakes.dart';
import '../sizing/sizing_screen_test.dart' show upBill, upLead;

final siteLead = upLead.copyWith(lat: 26.8467, lng: 80.9462);

/// A surveyed roof that allows 2 kW.
const smallRoof = Site(
  id: 's1',
  leadId: 'l1',
  roofType: RoofType.rcc,
  usableAreaSqm: 24,
  fittedPanelCount: 4,
  fittedKw: 2.16,
  maxKw: 2,
);

Future<void> open(
  WidgetTester tester,
  String route, {
  FakeSurveyRepository? survey,
  Size size = const Size(420, 900),
  List<Bill> bills = const [upBill],
}) async {
  await pumpApp(
    tester,
    session: readyAs(UserRole.sales),
    size: size,
    leads: FakeLeadsRepository(leads: [siteLead]),
    bills: FakeBillsRepository(bills: bills),
    proposals: FakeProposalsRepository(photos: 4),
    survey: survey,
  );
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
  await tester.pumpAndSettle();
}

void main() {
  test('GeoJSON round trip and compass points', () {
    const roof = [LatLng(26.1, 80.1), LatLng(26.1, 80.2), LatLng(26.2, 80.2)];
    expect(polygonFromGeoJson(polygonToGeoJson(roof)), roof);
    expect(polygonFromGeoJson('not json'), isEmpty);
    expect(compassPoint(180), 'S');
    expect(compassPoint(0), 'N');
    expect(compassPoint(225), 'SW');
    expect(compassPoint(350), 'N');
  });

  testWidgets(
    'drawing the roof shows area and panels that fit; save stores it',
    (tester) async {
      final survey = FakeSurveyRepository();
      await open(tester, Routes.survey('l1'), survey: survey);
      expect(
        find.text('Tap at least 3 corners to draw the roof'),
        findsOneWidget,
      );

      for (final p in const [
        Offset(110, 200),
        Offset(310, 200),
        Offset(310, 330),
        Offset(110, 330),
      ]) {
        await tester.tapAt(p);
        await tester.pumpAndSettle();
      }
      final panels = int.parse(
        tester.widget<Text>(find.byKey(const Key('survey.panels'))).data!,
      );
      expect(panels, greaterThan(0));
      expect(find.byKey(const Key('survey.maxKw')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('RCC (concrete)'),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('RCC (concrete)'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('survey.save')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const Key('survey.save')));
      await tester.pumpAndSettle();

      expect(survey.saved, hasLength(1));
      final saved = survey.saved.single;
      expect(saved.roof, hasLength(4));
      expect(saved.roofType, RoofType.rcc);
      expect(saved.layout.panelCount, panels);
      expect(saved.layout.areaSqm, greaterThan(50));
    },
  );

  testWidgets('undo removes the last corner', (tester) async {
    await open(tester, Routes.survey('l1'));
    for (final p in const [
      Offset(110, 200),
      Offset(310, 200),
      Offset(310, 330),
    ]) {
      await tester.tapAt(p);
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('survey.panels')), findsOneWidget);
    await tester.tap(find.byKey(const Key('survey.undo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('survey.panels')), findsNothing);
  });

  testWidgets('surveyed roof limits sizing (300 units wants 2.5 kW → 2 kW)', (
    tester,
  ) async {
    await open(
      tester,
      Routes.sizing('l1'),
      survey: FakeSurveyRepository(site: smallRoof),
      size: const Size(420, 2600),
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('sizing.recommended'))).data,
      '2 kW',
    );
    expect(find.text('Limited by roof area (max 2 kW).'), findsOneWidget);
  });

  testWidgets(
    'proposal warns above the roof limit; roof type passes compliance',
    (tester) async {
      await open(
        tester,
        Routes.newProposal('l1'),
        survey: FakeSurveyRepository(site: smallRoof),
        size: const Size(420, 3200),
      );
      // Default 3 kW → 6 × 540 Wp = 3.24 kW > 2 kW roof limit.
      expect(find.byKey(const Key('proposal.roofLimit')), findsOneWidget);
      final roofTypeRow = find.widgetWithText(ListTile, 'Roof type recorded');
      expect(
        find.descendant(
          of: roofTypeRow,
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byKey(const Key('proposal.kw')), '2');
      await tester.pumpAndSettle();
      // 2 kW → 4 × 540 = 2.16 kW, still above 2 kW.
      expect(find.byKey(const Key('proposal.roofLimit')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('proposal.kw')), '1.6');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('proposal.roofLimit')), findsNothing);
    },
  );
}
