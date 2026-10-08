import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solarkatha/core/router/routes.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/features/bills/domain/bill.dart';
import 'package:solarkatha/features/leads/domain/lead.dart';

import '../../helpers/fakes.dart';

final upLead = Lead(
  id: 'l1',
  companyId: demoCompany.id,
  assignedTo: 'u-sales',
  name: 'Ramesh Gupta',
  phone: '9876543210',
  stateCode: 'UP',
  consentAt: DateTime(2026, 10, 1),
  createdAt: DateTime(2026, 10, 1),
);

const upBill = Bill(
  id: 'b1',
  companyId: 'c1',
  leadId: 'l1',
  discom: 'MVVNL',
  avgMonthlyUnits: 300,
  sanctionedLoadKw: 3,
  billAmount: 2100,
);

Future<void> openSizing(WidgetTester tester, {String language = 'en'}) async {
  await pumpApp(
    tester,
    session: readyAs(UserRole.sales, language: language),
    language: language,
    size: const Size(420, 2600),
    leads: FakeLeadsRepository(leads: [upLead]),
    bills: FakeBillsRepository(bills: [upBill]),
  );
  GoRouter.of(tester.element(find.byType(Scaffold).first))
      .go(Routes.sizing('l1'));
  await tester.pumpAndSettle();
}

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  testWidgets('recommends 2.5 kW for 300 units and offers 2 and 3 kW', (
    tester,
  ) async {
    await openSizing(tester);
    expect(textOf(tester, 'sizing.recommended'), '2.5 kW');
    expect(find.byKey(const Key('sizing.option.2.0')), findsOneWidget);
    expect(find.byKey(const Key('sizing.option.3.0')), findsOneWidget);
  });

  testWidgets('2 kW: ₹90,000 subsidy, ₹30,000 net, EMI ₹348 (7%, 10 y)', (
    tester,
  ) async {
    await openSizing(tester);
    await tester.tap(find.byKey(const Key('sizing.option.2.0')));
    await tester.pumpAndSettle();
    // Central 2 × 30,000 + UP 30,000 (cap).
    expect(textOf(tester, 'sizing.totalSubsidy'), '₹90,000');
    // 2 × 60,000 − 90,000.
    expect(textOf(tester, 'sizing.net'), '₹30,000');
    expect(textOf(tester, 'sizing.emi'), '₹348');
    expect(textOf(tester, 'sizing.bill'), '₹2,100');
  });

  testWidgets('3 kW: ₹1,08,000 subsidy, ₹72,000 net, EMI ₹836', (tester) async {
    await openSizing(tester);
    await tester.tap(find.byKey(const Key('sizing.option.3.0')));
    await tester.pumpAndSettle();
    // Central capped at 78,000 + UP 30,000.
    expect(textOf(tester, 'sizing.totalSubsidy'), '₹1,08,000');
    expect(textOf(tester, 'sizing.net'), '₹72,000');
    expect(textOf(tester, 'sizing.emi'), '₹836');
    expect(find.text("EMI is lower than today's bill"), findsOneWidget);
  });

  testWidgets('non-DCR panels remove the subsidy', (tester) async {
    await openSizing(tester);
    await tester.tap(find.byKey(const Key('sizing.option.3.0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sizing.dcr')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'sizing.totalSubsidy'), '₹0');
    expect(textOf(tester, 'sizing.net'), '₹1,80,000');
    expect(
      find.text('No subsidy: panels must be DCR and ALMM-listed.'),
      findsOneWidget,
    );
  });

  testWidgets('sizing in Hindi keeps Indian number format', (tester) async {
    await openSizing(tester, language: 'hi');
    await tester.tap(find.byKey(const Key('sizing.option.3.0')));
    await tester.pumpAndSettle();
    expect(find.text('कुल सब्सिडी'), findsWidgets);
    expect(textOf(tester, 'sizing.totalSubsidy'), '₹1,08,000');
  });
}
