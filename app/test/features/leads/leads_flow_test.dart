import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/features/leads/data/leads_repository.dart';
import 'package:solarkatha/features/leads/domain/lead.dart';

import '../../helpers/fakes.dart';

Lead sampleLead({
  String id = 'l1',
  String name = 'Ramesh Gupta',
  LeadStatus status = LeadStatus.newLead,
  DateTime? followUp,
  String assignedTo = 'u-sales',
}) => Lead(
  id: id,
  companyId: demoCompany.id,
  assignedTo: assignedTo,
  name: name,
  phone: '9876543210',
  district: 'Lucknow',
  pincode: '226010',
  status: status,
  nextFollowUpAt: followUp,
  createdAt: DateTime.now(),
);

void main() {
  const phone = Size(360, 760);

  testWidgets('sales rep adds a lead offline; it shows as not synced', (
    tester,
  ) async {
    final repo = FakeLeadsRepository();
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales),
      size: phone,
      leads: repo,
    );

    await tester.tap(find.byKey(const Key('home.newLead')));
    await tester.pumpAndSettle();
    expect(find.text('Customer name'), findsOneWidget);

    // Validation: empty form is rejected.
    await tester.tap(find.byKey(const Key('leadForm.save')));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
    expect(repo.leads, isEmpty);

    await tester.enterText(
      find.byKey(const Key('leadForm.name')),
      'Sunita Devi',
    );
    await tester.enterText(
      find.byKey(const Key('leadForm.phone')),
      '98765 43210',
    );
    await tester.tap(find.byKey(const Key('leadForm.consent')));
    await tester.tap(find.byKey(const Key('leadForm.save')));
    await tester.pumpAndSettle();

    expect(repo.leads, hasLength(1));
    final saved = repo.leads.single;
    expect(saved.name, 'Sunita Devi');
    expect(saved.phone, '9876543210');
    expect(saved.assignedTo, 'u-sales');
    expect(saved.stateCode, 'UP', reason: 'defaults to company state');
    expect(saved.hasConsent, isTrue);

    // Lands on the lead detail page.
    expect(find.text('Sunita Devi'), findsWidgets);
    expect(find.text('Not synced'), findsOneWidget);
    expect(find.text('Change status'), findsOneWidget);

    // Site photos live in the Survey tab.
    await tester.tap(find.text('Survey'));
    await tester.pumpAndSettle();
    expect(find.text('Site photos'), findsOneWidget);
  });

  testWidgets('leads list filters by status and search', (tester) async {
    final repo = FakeLeadsRepository(
      leads: [
        sampleLead(id: 'a', name: 'Ramesh Gupta'),
        sampleLead(id: 'b', name: 'Sita Verma', status: LeadStatus.won),
      ],
    );
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales),
      size: phone,
      leads: repo,
    );
    await tester.tap(find.text('Leads').last);
    await tester.pumpAndSettle();

    expect(find.text('Ramesh Gupta'), findsOneWidget);
    expect(find.text('Sita Verma'), findsOneWidget);
    expect(find.text('All · 2'), findsOneWidget);

    await tester.tap(find.text('New · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Ramesh Gupta'), findsOneWidget);
    expect(find.text('Sita Verma'), findsNothing);

    await tester.tap(find.text('New · 1'));
    await tester.enterText(find.byType(TextField).first, 'ramesh');
    await tester.pumpAndSettle();
    expect(find.text('Ramesh Gupta'), findsOneWidget);
    expect(find.text('Sita Verma'), findsNothing);
  });

  testWidgets('changing status updates the lead', (tester) async {
    final repo = FakeLeadsRepository(leads: [sampleLead()]);
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales),
      size: phone,
      leads: repo,
    );
    await tester.tap(find.text('Leads').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ramesh Gupta'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Surveyed'));
    await tester.pumpAndSettle();
    expect(repo.leads.single.status, LeadStatus.surveyed);
  });

  testWidgets('home shows counts and today\'s follow-ups', (tester) async {
    final repo = FakeLeadsRepository(
      leads: [
        sampleLead(
          id: 'a',
          name: 'Due Today',
          followUp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        sampleLead(id: 'b', name: 'No Follow Up', status: LeadStatus.surveyed),
      ],
    );
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales),
      size: phone,
      leads: repo,
    );
    expect(find.text('Due Today'), findsOneWidget);
    expect(find.text('No Follow Up'), findsNothing);
    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('lead form in Hindi', (tester) async {
    await pumpApp(
      tester,
      session: readyAs(UserRole.sales, language: 'hi'),
      language: 'hi',
      size: phone,
    );
    await tester.tap(find.byKey(const Key('home.newLead')));
    await tester.pumpAndSettle();
    expect(find.text('ग्राहक का नाम'), findsOneWidget);
    expect(find.text('लीड सेव करें'), findsOneWidget);
  });

  test('LeadFilter has value equality (used as a provider key)', () {
    expect(
      const LeadFilter(query: 'a', status: LeadStatus.won),
      const LeadFilter(query: 'a', status: LeadStatus.won),
    );
  });
}
