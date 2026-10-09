import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solarkatha/core/router/app_router.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/features/admin/data/admin_repository.dart';
import 'package:solarkatha/features/auth/application/app_session.dart';
import 'package:solarkatha/features/projects/domain/project.dart';

import '../../helpers/fakes.dart';
import '../leads/leads_flow_test.dart' show sampleLead;

void go(WidgetTester tester, String path) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(appRouterProvider)
        .go(path);

void main() {
  const phone = Size(400, 860);
  const wide = Size(1280, 900);

  testWidgets('installer sees the project, marks the running stage done', (
    tester,
  ) async {
    final projects = FakeProjectsRepository(projects: [sampleProject()]);
    await pumpApp(
      tester,
      session: readyAs(UserRole.installer),
      size: phone,
      projects: projects,
      leads: FakeLeadsRepository(leads: [sampleLead()]),
    );
    expect(find.text('Ramesh Gupta'), findsOneWidget);
    expect(find.text('DISCOM feasibility approval'), findsOneWidget);
    expect(find.text('1 of 10 stages done'), findsOneWidget);

    await tester.tap(find.byKey(const Key('project.p1')));
    await tester.pumpAndSettle();
    expect(find.text('Registration on the national portal'), findsOneWidget);
    // Installers don't get the lead page.
    expect(find.byTooltip('Open project'), findsNothing);

    await tester.tap(find.byKey(const Key('stage.done.discom_feasibility')));
    await tester.pumpAndSettle();
    expect(projects.completed, [StageKind.discomFeasibility]);
    expect(find.text('Stage marked done'), findsOneWidget);
    expect(find.text('2 of 10 stages done'), findsOneWidget);
    expect(find.byKey(const Key('stage.done.vendor_selected')), findsOneWidget);
  });

  testWidgets('lead Project tab links to the project', (tester) async {
    await pumpApp(
      tester,
      session: readyAs(UserRole.owner),
      size: phone,
      projects: FakeProjectsRepository(projects: [sampleProject()]),
      leads: FakeLeadsRepository(leads: [sampleLead()]),
    );
    go(tester, '/leads/l1');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Project'));
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lead.openProject')), findsOneWidget);
    expect(find.text('1 of 10 stages done'), findsOneWidget);
  });

  testWidgets('owner dashboard shows live KPIs and projects by stage', (
    tester,
  ) async {
    await pumpApp(
      tester,
      session: readyAs(UserRole.owner),
      size: wide,
      admin: FakeAdminRepository(
        stats: const DashboardStats(
          kwSold: 8.5,
          revenue: 40800,
          subsidiesPending: 2,
          activeProjects: 3,
          byStage: {StageKind.installation: 2, StageKind.inspection: 1},
        ),
      ),
    );
    expect(find.text('8.5 kW'), findsOneWidget);
    expect(find.text('₹40,800'), findsOneWidget);
    expect(find.text('Active projects'), findsOneWidget);
    expect(find.text('Projects by stage'), findsOneWidget);
    expect(find.text('Installation'), findsOneWidget);
    expect(find.text('Inspection'), findsOneWidget);

    await tester.tap(find.byKey(const Key('notifications.bell')));
    await tester.pumpAndSettle();
    expect(
      find.text('Stage done: Registration on the national portal'),
      findsOneWidget,
    );
  });

  testWidgets('team lists members with numbers and pending invites', (
    tester,
  ) async {
    final admin = FakeAdminRepository(
      memberList: const [
        Member(id: 'u-owner', name: 'Test owner', role: 'owner', active: true),
        Member(
          id: 'u-sales',
          name: 'Sunil',
          role: 'sales',
          active: true,
          leads: 12,
          won: 3,
          kw: 9,
        ),
      ],
    );
    await pumpApp(
      tester,
      session: readyAs(UserRole.owner),
      size: wide,
      admin: admin,
    );
    go(tester, '/team');
    await tester.pumpAndSettle();
    expect(find.text('Test owner (You)'), findsOneWidget);
    expect(find.text('Leads: 12 · Won: 3 · 9 kW'), findsOneWidget);
    expect(find.text('Raju'), findsOneWidget);
    await tester.tap(find.text('Deactivate'));
    expect(admin.activeChanges, [('u-sales', false)]);
  });

  group('customer tracking page', () {
    testWidgets('shows the proposal, signs and offers payment', (tester) async {
      final api = FakeTrackingApi(sampleTrackData());
      await pumpApp(
        tester,
        session: const SignedOut(),
        size: phone,
        tracking: api,
      );
      go(tester, '/t/${'a' * 48}');
      await tester.pumpAndSettle();
      expect(find.text('Namaste Ramesh'), findsOneWidget);
      expect(find.text('Your 3 kW rooftop solar system'), findsOneWidget);
      expect(find.text('Pay advance ₹20,400'), findsOneWidget);
      expect(
        find.text('Work starts after you sign the proposal.'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('track.sign')));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('track.pad')),
        const Offset(120, 40),
      );
      await tester.pumpAndSettle();
      // PNG encoding needs real async.
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('track.submitSignature')));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      expect(api.signatures.single, startsWith('data:image/png;base64,'));
      expect(find.text('Signed. Thank you!'), findsOneWidget);

      await tester.tap(find.byKey(const Key('track.lang')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ramesh'), findsOneWidget);
      expect(find.text('Namaste Ramesh'), findsNothing);
    });

    testWidgets('unknown link says so', (tester) async {
      await pumpApp(tester, session: const SignedOut(), size: phone);
      go(tester, '/t/${'b' * 48}');
      await tester.pumpAndSettle();
      expect(
        find.text('This link is not valid or has been turned off.'),
        findsOneWidget,
      );
    });
  });
}
