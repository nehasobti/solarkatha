import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../projects/data/projects_repository.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_ui.dart';

/// Subsidy tracker: every open project with its stage, days in stage and
/// the overdue ones first.
class SubsidyScreen extends ConsumerWidget {
  const SubsidyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final open =
        (ref.watch(projectListProvider).value ?? const <ProjectSummary>[])
            .where((p) => p.project.subsidyAmountReceived == null)
            .toList()
          ..sort((a, b) {
            final ao = a.current?.overdue(now) ?? false;
            final bo = b.current?.overdue(now) ?? false;
            if (ao != bo) return ao ? -1 : 1;
            return (b.current?.daysInStage(now) ?? 0).compareTo(
              a.current?.daysInStage(now) ?? 0,
            );
          });
    final overdue = open.where((p) => p.current?.overdue(now) ?? false).length;
    final pendingAmount = open.fold<double>(
      0,
      (s, p) => s + (p.project.expectedSubsidy ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSubsidy)),
      body: open.isEmpty
          ? EmptyState(
              icon: Icons.account_balance_outlined,
              title: l10n.navSubsidy,
              body: l10n.allOnTrack,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Stat(
                      label: l10n.kpiSubsidiesPending,
                      value: IndianFormat.number(
                        open.length,
                        languageCode: lang,
                      ),
                    ),
                    _Stat(
                      label: l10n.expectedSubsidyLabel,
                      value: IndianFormat.rupees(
                        pendingAmount,
                        languageCode: lang,
                      ),
                    ),
                    _Stat(
                      label: l10n.overdueTitle,
                      value: IndianFormat.number(overdue, languageCode: lang),
                      color: overdue > 0 ? theme.colorScheme.error : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final s in open)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => context.push(Routes.project(s.project.id)),
                      leading: Icon(
                        stageStatusIcon(
                          s.current?.status ?? StageStatus.pending,
                        ),
                        color: stageStatusColor(
                          s.current?.status ?? StageStatus.pending,
                        ),
                      ),
                      title: Text(s.customerName),
                      subtitle: Text(
                        '${stageLabel(l10n, s.project.currentStage)} · '
                        '${l10n.daysInStage('${s.current?.daysInStage(now) ?? 0}')}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (s.project.expectedSubsidy != null)
                            Text(
                              IndianFormat.rupees(
                                s.project.expectedSubsidy!,
                                languageCode: lang,
                              ),
                            ),
                          if (s.current?.overdue(now) ?? false)
                            Text(
                              l10n.overdue,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
