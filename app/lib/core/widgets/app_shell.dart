import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_role.dart';
import '../../features/auth/application/app_session.dart';
import '../../features/auth/application/session_controller.dart';
import '../l10n/l10n.dart';
import '../router/routes.dart';
import 'offline_banner.dart';

class _Destination {
  const _Destination(this.path, this.icon, this.label, {this.compact = true});

  final String path;
  final IconData icon;
  final String Function(AppLocalizations) label;

  /// Shown in the bottom bar on phones. Wide layouts show every destination.
  final bool compact;
}

List<_Destination> _destinationsFor(UserRole role) => switch (role) {
  UserRole.owner => [
    _Destination(
      Routes.dashboard,
      Icons.insights_outlined,
      (l) => l.navOverview,
    ),
    _Destination(Routes.leads, Icons.people_outline, (l) => l.navLeads),
    _Destination(
      Routes.projects,
      Icons.solar_power_outlined,
      (l) => l.navProjects,
    ),
    _Destination(
      Routes.subsidy,
      Icons.account_balance_outlined,
      (l) => l.navSubsidy,
      compact: false,
    ),
    _Destination(
      Routes.team,
      Icons.groups_outlined,
      (l) => l.navTeam,
      compact: false,
    ),
    _Destination(
      Routes.products,
      Icons.inventory_2_outlined,
      (l) => l.navProducts,
      compact: false,
    ),
    _Destination(
      Routes.config,
      Icons.tune_outlined,
      (l) => l.navConfig,
      compact: false,
    ),
    _Destination(
      Routes.branding,
      Icons.palette_outlined,
      (l) => l.navBranding,
      compact: false,
    ),
    _Destination(
      Routes.settings,
      Icons.settings_outlined,
      (l) => l.navSettings,
    ),
  ],
  UserRole.sales => [
    _Destination(Routes.home, Icons.home_outlined, (l) => l.navHome),
    _Destination(Routes.leads, Icons.people_outline, (l) => l.navLeads),
    _Destination(
      Routes.settings,
      Icons.settings_outlined,
      (l) => l.navSettings,
    ),
  ],
  UserRole.installer => [
    _Destination(
      Routes.projects,
      Icons.solar_power_outlined,
      (l) => l.navProjects,
    ),
    _Destination(
      Routes.settings,
      Icons.settings_outlined,
      (l) => l.navSettings,
    ),
  ],
};

/// Role-aware navigation: a bottom bar on phones, a side rail on wide screens
/// (the owner's web dashboard).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  static const wideBreakpoint = 900.0;

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).value;
    if (session is! Ready) return child;

    final l10n = context.l10n;
    final wide = MediaQuery.sizeOf(context).width >= wideBreakpoint;
    final all = _destinationsFor(session.profile.role);
    final shown = wide ? all : all.where((d) => d.compact).toList();
    final selected = shown.indexWhere(
      (d) => location == d.path || location.startsWith('${d.path}/'),
    );

    void go(int i) => context.go(shown[i].path);

    if (!wide) {
      return Scaffold(
        body: OfflineAware(child: child),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected < 0 ? 0 : selected,
          onDestinationSelected: go,
          destinations: [
            for (final d in shown)
              NavigationDestination(icon: Icon(d.icon), label: d.label(l10n)),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.sizeOf(context).width >= 1200,
            selectedIndex: selected < 0 ? null : selected,
            onDestinationSelected: go,
            labelType: MediaQuery.sizeOf(context).width >= 1200
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.company.name,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            destinations: [
              for (final d in shown)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label(l10n)),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: OfflineAware(child: child)),
        ],
      ),
    );
  }
}
