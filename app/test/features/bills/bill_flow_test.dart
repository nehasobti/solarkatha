import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solarkatha/core/router/routes.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/features/bills/domain/bill.dart';

import '../../helpers/fakes.dart';
import '../sizing/sizing_screen_test.dart' show upLead;

/// What the bill-scan function returns for a UP bill (see the Deno tests).
const scanResponse = <String, Object?>{
  'extraction': {
    'discom': 'MVVNL',
    'consumer_number': '1234567890',
    'customer_name': 'Ramesh Gupta',
    'tariff_category': 'LMV-1',
    'sanctioned_load_kw': 3,
    'billing_period': 'Aug 2026',
    'bill_amount': 2450,
    'units_history': [],
    'confidence': {
      'discom': 'high',
      'consumer_number': 'low',
      'bill_amount': 'high',
    },
  },
  'units_monthly': {'2026-07': 360, '2026-06': 410, '2026-05': 380},
  'avg_monthly_units': 383,
};

void main() {
  test('scan response prefills the bill form', () {
    final i = BillInput.fromScan(scanResponse, photoId: 'p1');
    expect(i.discom, 'MVVNL');
    expect(i.consumerNumber, '1234567890');
    expect(i.sanctionedLoadKw, 3);
    expect(i.avgMonthlyUnits, 383);
    expect(i.billAmount, 2450);
    expect(i.unitsMonthly, hasLength(3));
    expect(i.confidence['consumer_number'], FieldConfidence.low);
    expect(i.source, 'scan');
    expect(i.photoId, 'p1');
  });

  test('history12 lines months up Jan..Dec', () {
    final bill = Bill(
      id: 'b',
      companyId: 'c',
      leadId: 'l',
      unitsMonthly: {
        for (var m = 1; m <= 12; m++)
          '2026-${m.toString().padLeft(2, '0')}': m * 10.0,
      },
    );
    expect(bill.history12!.first, 10);
    expect(bill.history12!.last, 120);
    expect(const Bill(id: 'b', companyId: 'c', leadId: 'l').history12, isNull);
  });

  test('averageUnits', () {
    expect(averageUnits({'a': 300, 'b': 400}), 350);
    expect(averageUnits({}), isNull);
  });

  testWidgets('reviewing a scan: AI-unsure field flagged, confirm saves', (
    tester,
  ) async {
    final bills = FakeBillsRepository(
      scans: [
        const ScanJob(
          id: 's1',
          leadId: 'l1',
          photoId: 'p1',
          status: ScanStatus.done,
          attempts: 1,
          result: scanResponse,
        ),
      ],
    );
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales),
      size: const Size(420, 1400),
      leads: FakeLeadsRepository(leads: [upLead]),
      bills: bills,
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go(Routes.newBill('l1', scanId: 's1'));
    await tester.pumpAndSettle();

    expect(find.text('383'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    // consumer_number was "low" confidence.
    expect(find.text('Please check: the AI was not sure'), findsOneWidget);

    await tester.tap(find.byKey(const Key('billForm.save')));
    await tester.pumpAndSettle();
    expect(bills.saved, hasLength(1));
    expect(bills.saved.single.avgMonthlyUnits, 383);
    expect(bills.saved.single.source, 'scan');
  });

  testWidgets('manual entry requires average units', (tester) async {
    final bills = FakeBillsRepository();
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales),
      size: const Size(420, 1400),
      leads: FakeLeadsRepository(leads: [upLead]),
      bills: bills,
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go(Routes.newBill('l1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('billForm.save')));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
    expect(bills.saved, isEmpty);

    await tester.enterText(find.byKey(const Key('billForm.avg')), '250');
    await tester.tap(find.byKey(const Key('billForm.save')));
    await tester.pumpAndSettle();
    expect(bills.saved.single.avgMonthlyUnits, 250);
    expect(bills.saved.single.source, 'manual');
  });

  testWidgets('warns when the consumer number is on another lead', (
    tester,
  ) async {
    final bills = FakeBillsRepository(
      bills: [
        const Bill(
          id: 'old',
          companyId: 'c1',
          leadId: 'other-lead',
          consumerNumber: '1234567890',
        ),
      ],
      scans: [
        const ScanJob(
          id: 's1',
          leadId: 'l1',
          photoId: 'p1',
          status: ScanStatus.done,
          attempts: 1,
          result: scanResponse,
        ),
      ],
    );
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales),
      size: const Size(420, 1400),
      leads: FakeLeadsRepository(leads: [upLead]),
      bills: bills,
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go(Routes.newBill('l1', scanId: 's1'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Only one central subsidy is allowed'),
      findsOneWidget,
    );
  });
}
