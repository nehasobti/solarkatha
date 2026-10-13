import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin/presentation/branding_screen.dart';
import '../../features/admin/presentation/config_screen.dart';
import '../../features/admin/presentation/notifications_screen.dart';
import '../../features/admin/presentation/subsidy_screen.dart';
import '../../features/admin/presentation/team_screen.dart';
import '../../features/auth/application/app_session.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/auth/presentation/deactivated_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/bills/presentation/bill_form_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/sizing/presentation/sizing_screen.dart';
import '../../features/survey/presentation/survey_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/landing/presentation/landing_screen.dart';
import '../../features/leads/presentation/lead_detail_screen.dart';
import '../../features/leads/presentation/lead_form_screen.dart';
import '../../features/leads/presentation/leads_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/proposals/presentation/proposal_builder_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tracking/presentation/tracking_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/not_found_screen.dart';
import '../widgets/offline_banner.dart';
import 'redirect.dart';
import 'routes.dart';

part 'app_router.g.dart';

NoTransitionPage<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);

/// Owner sections in the shell.
final _ownerSections = <(String, Widget)>[
  (Routes.subsidy, const SubsidyScreen()),
  (Routes.team, const TeamScreen()),
  (Routes.config, const ConfigScreen()),
  (Routes.branding, const BrandingScreen()),
];

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final session = ValueNotifier<AsyncValue<AppSession>>(
    ref.read(sessionControllerProvider),
  );
  ref
    ..listen(sessionControllerProvider, (_, next) => session.value = next)
    ..onDispose(session.dispose);

  final router = GoRouter(
    refreshListenable: session,
    redirect: (context, state) =>
        resolveRedirect(session: session.value, uri: state.uri, web: kIsWeb),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.deactivated,
        builder: (context, state) => const DeactivatedScreen(),
      ),
      GoRoute(
        path: Routes.landing,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '${Routes.trackingPrefix}:token',
        builder: (context, state) =>
            TrackingScreen(token: state.pathParameters['token']!),
      ),
      // Full-screen lead pages (no bottom bar), listed before the shell so
      // they win over /leads.
      GoRoute(
        path: Routes.newLead,
        builder: (context, state) =>
            const OfflineAware(child: LeadFormScreen()),
      ),
      GoRoute(
        path: '${Routes.leads}/:id',
        builder: (context, state) => OfflineAware(
          child: LeadDetailScreen(leadId: state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'bill/new',
            builder: (context, state) => OfflineAware(
              child: BillFormScreen(
                leadId: state.pathParameters['id']!,
                scanId: state.uri.queryParameters['scan'],
              ),
            ),
          ),
          GoRoute(
            path: 'bill/:billId',
            builder: (context, state) => OfflineAware(
              child: BillFormScreen(
                leadId: state.pathParameters['id']!,
                billId: state.pathParameters['billId'],
              ),
            ),
          ),
          GoRoute(
            path: 'proposals/new',
            builder: (context, state) => OfflineAware(
              child: ProposalBuilderScreen(
                leadId: state.pathParameters['id']!,
                initialKw: double.tryParse(
                  state.uri.queryParameters['kw'] ?? '',
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'proposals/:proposalId',
            builder: (context, state) => OfflineAware(
              child: ProposalBuilderScreen(
                leadId: state.pathParameters['id']!,
                proposalId: state.pathParameters['proposalId'],
              ),
            ),
          ),
          GoRoute(
            path: 'survey',
            builder: (context, state) => OfflineAware(
              child: SurveyScreen(leadId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'sizing',
            builder: (context, state) => OfflineAware(
              child: SizingScreen(leadId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => OfflineAware(
              child: LeadFormScreen(leadId: state.pathParameters['id']),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '${Routes.projects}/:id',
        builder: (context, state) => OfflineAware(
          child: ProjectDetailScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => _page(state, const HomeScreen()),
          ),
          GoRoute(
            path: Routes.leads,
            pageBuilder: (context, state) => _page(state, const LeadsScreen()),
          ),
          GoRoute(
            path: Routes.projects,
            pageBuilder: (context, state) =>
                _page(state, const ProjectsScreen()),
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (context, state) =>
                _page(state, const SettingsScreen()),
          ),
          GoRoute(
            path: Routes.products,
            pageBuilder: (context, state) =>
                _page(state, const ProductsScreen()),
          ),
          GoRoute(
            path: Routes.dashboard,
            pageBuilder: (context, state) =>
                _page(state, const DashboardScreen()),
          ),
          for (final (path, screen) in _ownerSections)
            GoRoute(
              path: path,
              pageBuilder: (context, state) => _page(state, screen),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
