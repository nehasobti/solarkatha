import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/widgets/offline_banner.dart';

import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/presentation/notifications_screen.dart';
import '../../leads/application/leads_providers.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_ui.dart';
import '../../leads/domain/lead.dart';
import '../../leads/presentation/lead_ui.dart';

/// Owner overview: KPIs, lead funnel, projects by stage and shortcuts to the
/// owner sections (which phones don't show in the bottom bar).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = ref.watch(
      appPreferencesControllerProvider.select((p) => p.languageCode),
    );
    final company = ref.watch(currentMemberProvider)?.company.name ?? '';
    final counts = ref.watch(leadStatusCountsProvider).value ?? const {};
    final thisMonth = ref.watch(leadsThisMonthProvider).value ?? 0;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final won = counts[LeadStatus.won] ?? 0;
    final lost = counts[LeadStatus.lost] ?? 0;
    final closed = won + lost;
    final conversion = closed == 0 ? 0 : (won * 100 / closed).round();
    final stats =
        ref.watch(dashboardStatsProvider).value ?? const DashboardStats();

    final kpis = <(String, String, IconData)>[
      (
        l10n.kpiLeadsThisMonth,
        IndianFormat.number(thisMonth, languageCode: lang),
        Icons.people_outline,
      ),
      (l10n.kpiConversion, '$conversion%', Icons.trending_up),
      (
        l10n.kpiKwSold,
        IndianFormat.kw(stats.kwSold, languageCode: lang),
        Icons.solar_power_outlined,
      ),
      (
        l10n.kpiRevenue,
        IndianFormat.rupees(stats.revenue, languageCode: lang),
        Icons.currency_rupee,
      ),
      (
        l10n.kpiSubsidiesPending,
        IndianFormat.number(stats.subsidiesPending, languageCode: lang),
        Icons.account_balance_outlined,
      ),
      (
        l10n.kpiActiveProjects,
        IndianFormat.number(stats.activeProjects, languageCode: lang),
        Icons.engineering_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.navOverview} · $company'),
        actions: [
          IconButton(
            tooltip: l10n.exportCsv,
            icon: const Icon(Icons.download_outlined),
            onPressed: () async {
              final rows = await ref
                  .read(adminRepositoryProvider)
                  .leadsForExport();
              final cols = [
                'name',
                'phone',
                'district',
                'state_code',
                'source',
                'status',
                'assigned_to',
                'created_at',
                'next_follow_up_at',
              ];
              await exportCsv('solarkatha-leads.csv', cols, [
                for (final r in rows) [for (final c in cols) r[c]],
              ]);
            },
          ),
          const NotificationBell(),
          const SyncChip(),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (label, value, icon) in kpis)
                SizedBox(
                  width: 200,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            value,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(label, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.pipelineTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: total == 0
                  ? Text(l10n.dashboardEmpty, style: theme.textTheme.bodyLarge)
                  : Column(
                      children: [
                        for (final s in LeadStatus.values)
                          _FunnelRow(
                            status: s,
                            count: counts[s] ?? 0,
                            max: counts.values.fold<int>(
                              1,
                              (a, b) => b > a ? b : a,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.projectsByStage, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: stats.byStage.isEmpty
                  ? Text(
                      l10n.projectsEmptyBody,
                      style: theme.textTheme.bodyLarge,
                    )
                  : Column(
                      children: [
                        for (final k in StageKind.values)
                          if ((stats.byStage[k] ?? 0) > 0)
                            _BarRow(
                              label: stageLabel(l10n, k),
                              count: stats.byStage[k]!,
                              max: stats.byStage.values.fold<int>(
                                1,
                                (a, b) => b > a ? b : a,
                              ),
                              color: const Color(0xFFE07B00),
                              onTap: () => context.go(Routes.subsidy),
                            ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (path, icon, label) in [
                (
                  Routes.subsidy,
                  Icons.account_balance_outlined,
                  l10n.navSubsidy,
                ),
                (Routes.team, Icons.groups_outlined, l10n.navTeam),
                (Routes.products, Icons.inventory_2_outlined, l10n.navProducts),
                (Routes.config, Icons.tune_outlined, l10n.navConfig),
                (Routes.branding, Icons.palette_outlined, l10n.navBranding),
              ])
                ActionChip(
                  avatar: Icon(icon, size: 18),
                  label: Text(label),
                  onPressed: () => context.go(path),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.count,
    required this.max,
    required this.color,
    this.onTap,
  });

  final String label;
  final int count;
  final int max;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: Text(label, style: theme.textTheme.bodyMedium),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 22,
                    width: (c.maxWidth * count / max).clamp(4, c.maxWidth),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$count',
                textAlign: TextAlign.end,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunnelRow extends StatelessWidget {
  const _FunnelRow({
    required this.status,
    required this.count,
    required this.max,
  });

  final LeadStatus status;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              status.label(context.l10n),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 22,
                  width: (c.maxWidth * count / max).clamp(4, c.maxWidth),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
