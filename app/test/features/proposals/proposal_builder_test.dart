import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solarkatha/core/router/routes.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/features/bills/domain/bill.dart';
import 'package:solarkatha/features/proposals/domain/proposal.dart';
import 'package:solarkatha/features/survey/domain/site.dart';

import '../../helpers/fakes.dart';
import '../sizing/sizing_screen_test.dart' show upLead;

const billWithConsumer = Bill(
  id: 'b1',
  companyId: 'c1',
  leadId: 'l1',
  discom: 'MVVNL',
  consumerNumber: '4521778309',
  avgMonthlyUnits: 316,
  billAmount: 2450,
);

Future<FakeProposalsRepository> openBuilder(
  WidgetTester tester, {
  UserRole role = UserRole.sales,
  int photos = 0,
  String? route,
}) async {
  final repo = FakeProposalsRepository(photos: photos);
  await pumpApp(
    tester,
    session: readyAs(role),
    size: const Size(420, 3200),
    leads: FakeLeadsRepository(
      leads: [upLead.copyWith(assignedTo: 'u-${role.name}')],
    ),
    bills: FakeBillsRepository(bills: [billWithConsumer]),
    proposals: repo,
    // Surveyed roof: roof type recorded (compliance), roof allows 5 kW.
    survey: FakeSurveyRepository(
      site: const Site(
        id: 's1',
        leadId: 'l1',
        roofType: RoofType.rcc,
        maxKw: 5,
      ),
    ),
  );
  GoRouter.of(tester.element(find.byType(Scaffold).first))
      .go(route ?? Routes.newProposal('l1'));
  await tester.pumpAndSettle();
  return repo;
}

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  testWidgets('DCR panel: 6 × 540 Wp = 3.24 kW, subsidy and net computed', (
    tester,
  ) async {
    await openBuilder(tester);
    expect(find.text('6 panels × 540 Wp = 3.24 kW'), findsOneWidget);
    // 3.24 kW × ₹60,000 = ₹1,94,400; subsidy 78,000 + 30,000.
    expect(textOf(tester, 'proposal.net'), '₹86,400');
    expect(
      find.text('No subsidy: panels must be DCR and ALMM-listed.'),
      findsNothing,
    );
  });

  testWidgets('non-DCR panel gives no subsidy', (tester) async {
    await openBuilder(tester);
    await tester.tap(find.byKey(const Key('proposal.panel')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generic 550 imported').last);
    await tester.pumpAndSettle();
    expect(
      find.text('No subsidy: panels must be DCR and ALMM-listed.'),
      findsOneWidget,
    );
    // 6 × 550 = 3.3 kW × 60,000, no subsidy.
    expect(textOf(tester, 'proposal.net'), '₹1,98,000');
  });

  testWidgets(
    'saving creates a draft; sending stays blocked until checklist passes',
    (tester) async {
      final repo = await openBuilder(tester, photos: 4);
      await tester.tap(find.byKey(const Key('proposal.save')));
      await tester.pumpAndSettle();
      expect(repo.proposals, hasLength(1));
      final p = repo.proposals.single;
      expect(p.status, ProposalStatus.draft);
      expect(p.systemKw, closeTo(3.24, 1e-9));
      expect(p.panelCount, 6);
      expect(p.totalSubsidy, 108000);
      expect(p.netPrice, 86400);
      expect(p.loan!.emi, greaterThan(0));
      expect(p.monthlyGeneration, hasLength(12));

      // Own connection and roof type not ticked → actions blocked.
      expect(
        find.text(
          'Finish the checklist before sending. Only the owner can override.',
        ),
        findsOneWidget,
      );
      final whatsapp = tester.widget<FilledButton>(
        find.byKey(const Key('proposal.whatsapp')),
      );
      expect(whatsapp.onPressed, isNull);

      await tester.tap(find.byKey(const Key('compliance.ownConnection')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Finish the checklist before sending. Only the owner can override.',
        ),
        findsNothing,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('proposal.whatsapp')))
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('only owners see the override switch', (tester) async {
    await openBuilder(tester);
    expect(find.byKey(const Key('compliance.override')), findsNothing);
  });

  testWidgets('owner can override failing checks', (tester) async {
    await openBuilder(tester, role: UserRole.owner);
    expect(find.byKey(const Key('compliance.override')), findsOneWidget);
  });

  testWidgets('proposal builder in Hindi', (tester) async {
    final repo = FakeProposalsRepository();
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales, language: 'hi'),
      language: 'hi',
      size: const Size(420, 3200),
      leads: FakeLeadsRepository(leads: [upLead]),
      bills: FakeBillsRepository(bills: [billWithConsumer]),
      proposals: repo,
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go(Routes.newProposal('l1'));
    await tester.pumpAndSettle();
    expect(find.text('अनुपालन चेकलिस्ट'), findsOneWidget);
    expect(textOf(tester, 'proposal.net'), '₹86,400');
  });

  test('fillTemplate replaces known placeholders only', () {
    expect(
      fillTemplate('Hi {customer_name}, {x}', {'customer_name': 'Ramesh'}),
      'Hi Ramesh, {x}',
    );
  });
}
