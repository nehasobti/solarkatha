import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/domain/lead.dart';
import '../../leads/presentation/lead_ui.dart';

/// Owner overview. Lead KPIs and the pipeline are live; kW, revenue and
/// subsidy figures arrive with proposals and projects (Phases 4 and 6).
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

    final kpis = <(String, String, IconData)>[
      (
        l10n.kpiLeadsThisMonth,
        IndianFormat.number(thisMonth, languageCode: lang),
        Icons.people_outline,
      ),
      (l10n.kpiConversion, '$conversion%', Icons.trending_up),
      (
        l10n.kpiKwSold,
        IndianFormat.kw(0, languageCode: lang),
        Icons.solar_power_outlined,
      ),
      (
        l10n.kpiRevenue,
        IndianFormat.rupees(0, languageCode: lang),
        Icons.currency_rupee,
      ),
      (
        l10n.kpiSubsidiesPending,
        IndianFormat.number(0, languageCode: lang),
        Icons.account_balance_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.navOverview} · $company'),
        actions: const [SyncChip(), SizedBox(width: 12)],
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
        ],
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
