import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/user_role.dart';
import '../../leads/application/leads_providers.dart';
import '../../admin/presentation/notifications_screen.dart';
import '../data/projects_repository.dart';
import '../domain/project.dart';
import 'project_ui.dart';

/// Projects: installers see the ones assigned to them, owners see all.
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final projects = ref.watch(projectListProvider);
    final isOwner =
        ref.watch(currentMemberProvider)?.profile.role == UserRole.owner;
    final list = projects.value ?? const <ProjectSummary>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProjects),
        actions: [
          const NotificationBell(),
          if (isOwner && list.isNotEmpty)
            IconButton(
              tooltip: l10n.exportCsv,
              icon: const Icon(Icons.download_outlined),
              onPressed: () => exportCsv(
                'solarkatha-projects.csv',
                [
                  'customer',
                  'system_kw',
                  'net_price',
                  'current_stage',
                  'stage_status',
                  'stages_done',
                  'signed_at',
                  'subsidy_received',
                ],
                [
                  for (final p in list)
                    [
                      p.customerName,
                      p.project.systemKw,
                      p.project.netPrice,
                      p.project.currentStage.dbValue,
                      p.current?.status.dbValue,
                      p.doneCount,
                      p.project.signedAt?.toIso8601String().substring(0, 10),
                      p.project.subsidyAmountReceived,
                    ],
                ],
              ),
            ),
        ],
      ),
      body: projects.isLoading && list.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
          ? EmptyState(
              icon: Icons.solar_power_outlined,
              title: l10n.projectsEmptyTitle,
              body: l10n.projectsEmptyBody,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) =>
                  ProjectCard(summary: list[i], lang: lang),
            ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.summary, required this.lang});

  final ProjectSummary summary;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = summary.project;
    final current = summary.current;
    final overdue = current?.overdue(DateTime.now()) ?? false;
    final status = p.isComplete
        ? StageStatus.done
        : (current?.status ?? StageStatus.pending);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        key: Key('project.${p.id}'),
        onTap: () => context.push(Routes.project(p.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      summary.customerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (p.systemKw != null)
                    Text(
                      IndianFormat.kw(p.systemKw!, languageCode: lang),
                      style: theme.textTheme.titleSmall,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    stageStatusIcon(status),
                    size: 18,
                    color: stageStatusColor(status),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.isComplete
                          ? l10n.projectComplete
                          : stageLabel(l10n, p.currentStage),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (overdue)
                    Text(
                      l10n.overdue,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: summary.doneCount / 10,
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.stageProgress('${summary.doneCount}'),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
