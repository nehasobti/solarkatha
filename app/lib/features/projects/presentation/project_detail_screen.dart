import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/user_role.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/presentation/lead_ui.dart';
import '../../proposals/data/proposals_repository.dart';
import '../../proposals/domain/proposal.dart';
import '../data/projects_repository.dart';
import '../domain/project.dart';
import 'project_ui.dart';
import 'projects_screen.dart';

/// One project: tracking link, installers, the 10 subsidy stages with due
/// dates, notes and documents; "Mark done" offers a WhatsApp update.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary = ref.watch(projectSummaryProvider(projectId));
    final stages =
        ref.watch(projectStagesProvider(projectId)).value ?? const [];
    final s = summary.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          s == null
              ? l10n.projectTitle
              : '${l10n.projectTitle} · ${s.customerName}',
        ),
        actions: [
          if (s != null &&
              ref.watch(currentMemberProvider)?.profile.role !=
                  UserRole.installer)
            IconButton(
              tooltip: l10n.openProject,
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push(Routes.lead(s.project.leadId)),
            ),
        ],
      ),
      body: s == null
          ? (summary.isLoading
                ? const Center(child: CircularProgressIndicator())
                : EmptyState(icon: Icons.search_off, title: l10n.notFoundTitle))
          : _Body(summary: s, stages: stages),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.summary, required this.stages});

  final ProjectSummary summary;
  final List<StageRow> stages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = summary.project;
    final isOwner =
        ref.watch(currentMemberProvider)?.profile.role == UserRole.owner;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.stageProgress('${summary.doneCount}'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: summary.doneCount / 10,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF16A34A),
                    ),
                    const SizedBox(height: 12),
                    _TrackingLink(
                      project: p,
                      customerName: summary.customerName,
                    ),
                  ],
                ),
              ),
            ),
            if (isOwner) _Installers(project: p),
            for (final st in stages)
              _StageCard(
                stage: st,
                summary: summary,
                // Only the latest finished stage keeps Reopen / Send update.
                latestDone:
                    st.status == StageStatus.done &&
                    !stages.any(
                      (o) =>
                          o.status == StageStatus.done &&
                          o.position > st.position,
                    ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

Future<String?> trackingUrl(WidgetRef ref, Project p) async {
  final repo = ref.read(proposalsRepositoryProvider);
  final token = await ref
      .read(projectsRepositoryProvider)
      .shareToken(p.proposalId);
  final base = await repo.configValue('public_web_url', p.companyId);
  if (token == null || base is! String) return null;
  return '${base.replaceAll(RegExp(r'/$'), '')}/t/$token';
}

class _TrackingLink extends ConsumerWidget {
  const _TrackingLink({required this.project, required this.customerName});

  final Project project;
  final String customerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return FutureBuilder<String?>(
      future: trackingUrl(ref, project),
      builder: (context, snap) {
        final url = snap.data;
        if (url == null) return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.link, size: 18),
            Text(l10n.trackingLink),
            IconButton(
              tooltip: l10n.copyLink,
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
                }
              },
            ),
            FilledButton.tonalIcon(
              key: const Key('project.shareLink'),
              onPressed: () async {
                final lead = await ref.read(
                  leadProvider(project.leadId).future,
                );
                if (lead != null) await openWhatsApp(lead.phone, text: url);
              },
              icon: const Icon(Icons.chat),
              label: Text(l10n.shareTrackingLink),
            ),
            if (ref.watch(currentMemberProvider)?.profile.role ==
                UserRole.owner)
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(projectsRepositoryProvider)
                      .setLinkRevoked(project.proposalId, true);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.linkRevoked)),
                  );
                },
                child: Text(l10n.revokeLink),
              ),
          ],
        );
      },
    );
  }
}

class _Installers extends ConsumerWidget {
  const _Installers({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final team = (ref.watch(teamProvider).value ?? const [])
        .where((m) => m.role == 'installer')
        .toList();
    final assigned =
        ref.watch(projectAssigneesProvider(project.id)).value ?? const [];
    if (team.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.installersLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in team)
                  FilterChip(
                    label: Text(m.name),
                    selected: assigned.contains(m.id),
                    onSelected: (v) => ref
                        .read(projectsRepositoryProvider)
                        .setAssigned(
                          project: project,
                          profileId: m.id,
                          assigned: v,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageCard extends ConsumerWidget {
  const _StageCard({
    required this.stage,
    required this.summary,
    this.latestDone = false,
  });

  final StageRow stage;
  final ProjectSummary summary;
  final bool latestDone;

  Future<void> _sendUpdate(BuildContext context, WidgetRef ref) async {
    final p = summary.project;
    final lead = await ref.read(leadProvider(p.leadId).future);
    if (lead == null) return;
    final repo = ref.read(proposalsRepositoryProvider);
    final proposal = await ref.read(proposalProvider(p.proposalId).future);
    final lang = proposal?.language ?? 'en';
    final template = await repo.configValue(
      'wa_template_stage_$lang',
      p.companyId,
    );
    final url = await trackingUrl(ref, p) ?? '';
    final member = ref.read(currentMemberProvider);
    final l10n = lookupAppLocalizations(Locale(lang));
    await openWhatsApp(
      lead.phone,
      text: fillTemplate(
        template is String ? template : '{stage}: {tracking_link}',
        {
          'customer_name': lead.name,
          'company_name': member?.company.name ?? '',
          'system_kw': IndianFormat.kw(p.systemKw ?? 0, languageCode: lang),
          'stage': stageLabel(l10n, stage.kind),
          'tracking_link': url,
        },
      ),
    );
  }

  Future<void> _markDone(BuildContext context, WidgetRef ref) async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(projectsRepositoryProvider)
        .completeStage(stage, userId: member.profile.id);
    // The done stage now shows "Send update on WhatsApp".
    messenger.showSnackBar(SnackBar(content: Text(l10n.stageMarkedDone)));
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: stage.note);
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockedReason),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    await ref
        .read(projectsRepositoryProvider)
        .setStageStatus(stage, StageStatus.blocked, note: note);
  }

  Future<void> _addDocument(BuildContext context, WidgetRef ref) async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    final file = await ImagePicker().pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    await ref
        .read(projectsRepositoryProvider)
        .addDocument(
          stage: stage,
          companyId: member.company.id,
          userId: member.profile.id,
          jpeg: await file.readAsBytes(),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isOwner =
        ref.watch(currentMemberProvider)?.profile.role == UserRole.owner;
    final color = stageStatusColor(stage.status);
    final active =
        stage.status == StageStatus.inProgress ||
        stage.status == StageStatus.blocked;
    final overdue = stage.overdue(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? color : theme.colorScheme.outlineVariant,
          width: active ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: stage.status == StageStatus.done
                      ? Icon(Icons.check, size: 16, color: color)
                      : Text(
                          '${stage.position}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stageLabel(l10n, stage.kind),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  stageStatusLabel(l10n, stage.status),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stage.doneAt != null)
                    Text(
                      l10n.doneOn(formatDay(context, stage.doneAt!)),
                      style: theme.textTheme.bodySmall,
                    )
                  else if (stage.dueDate != null)
                    Text(
                      l10n.dueOn(formatDay(context, stage.dueDate!)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: overdue ? theme.colorScheme.error : null,
                        fontWeight: overdue ? FontWeight.w700 : null,
                      ),
                    ),
                  if ((stage.note ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        stage.note!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  _StageFields(stage: stage, project: summary.project),
                  if (active || latestDone)
                    Wrap(
                      spacing: 8,
                      children: [
                        if (stage.status == StageStatus.inProgress)
                          FilledButton.icon(
                            key: Key('stage.done.${stage.kind.dbValue}'),
                            onPressed: () => _markDone(context, ref),
                            icon: const Icon(Icons.check),
                            label: Text(l10n.markDone),
                          ),
                        if (stage.status == StageStatus.inProgress)
                          OutlinedButton(
                            onPressed: () => _block(context, ref),
                            child: Text(l10n.markBlocked),
                          ),
                        if (stage.status == StageStatus.blocked)
                          FilledButton.tonal(
                            onPressed: () => ref
                                .read(projectsRepositoryProvider)
                                .setStageStatus(stage, StageStatus.inProgress),
                            child: Text(l10n.resumeStage),
                          ),
                        if (active)
                          TextButton.icon(
                            onPressed: () => _addDocument(context, ref),
                            icon: const Icon(Icons.attach_file),
                            label: Text(l10n.addDocument),
                          ),
                        if (isOwner && latestDone)
                          TextButton(
                            onPressed: () => ref
                                .read(projectsRepositoryProvider)
                                .setStageStatus(stage, StageStatus.inProgress),
                            child: Text(l10n.reopenStage),
                          ),
                        if (latestDone)
                          TextButton.icon(
                            onPressed: () => _sendUpdate(context, ref),
                            icon: const Icon(Icons.chat_outlined),
                            label: Text(l10n.sendStageUpdate),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extra fields on the stages that produce a number or date.
class _StageFields extends ConsumerWidget {
  const _StageFields({required this.stage, required this.project});

  final StageRow stage;
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final repo = ref.read(projectsRepositoryProvider);
    final (
      String label,
      String? value,
      Future<void> Function()? edit,
    ) = switch (stage.kind) {
      StageKind.netMeterInstalled => (
        l10n.netMeterNumberLabel,
        project.netMeterNumber,
        () async {
          final v = await _ask(
            context,
            l10n.netMeterNumberLabel,
            project.netMeterNumber,
          );
          if (v != null) {
            await repo.updateProject(project.id, {
              'net_meter_number': v.trim(),
            });
          }
        },
      ),
      StageKind.commissioningCertificate => (
        l10n.commissioningDateLabel,
        project.commissioningDate == null
            ? null
            : formatDay(context, project.commissioningDate!),
        () async {
          final d = await showDatePicker(
            context: context,
            initialDate: project.commissioningDate ?? DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (d != null) {
            await repo.updateProject(project.id, {
              'commissioning_date': d.toIso8601String().substring(0, 10),
            });
          }
        },
      ),
      StageKind.subsidyCredited => (
        l10n.subsidyReceivedLabel,
        project.subsidyAmountReceived == null
            ? null
            : IndianFormat.rupees(
                project.subsidyAmountReceived!,
                languageCode: lang,
              ),
        () async {
          final v = await _ask(
            context,
            l10n.subsidyReceivedLabel,
            project.subsidyAmountReceived?.round().toString() ??
                project.expectedSubsidy?.round().toString(),
            number: true,
          );
          final amount = double.tryParse(v ?? '');
          if (amount != null) {
            await repo.updateProject(project.id, {
              'subsidy_amount_received': amount,
              'subsidy_received_at': DateTime.now().toUtc().toIso8601String(),
            });
          }
        },
      ),
      _ => ('', null, null),
    };
    if (edit == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: edit,
        child: Row(
          children: [
            Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
            Text(value ?? '—', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 4),
            const Icon(Icons.edit_outlined, size: 16),
          ],
        ),
      ),
    );
  }

  static Future<String?> _ask(
    BuildContext context,
    String title,
    String? initial, {
    bool number = false,
  }) async {
    final c = TextEditingController(text: initial);
    final l10n = context.l10n;
    final v = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          inputFormatters: number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    c.dispose();
    return v;
  }
}

/// Lead detail → Project tab.
class ProjectTab extends ConsumerWidget {
  const ProjectTab({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final project = ref.watch(leadProjectProvider(leadId)).value;
    if (project == null) {
      return EmptyState(
        icon: Icons.solar_power_outlined,
        title: l10n.tabProject,
        body: l10n.noProjectYet,
      );
    }
    final summary = ref.watch(projectSummaryProvider(project.id)).value;
    final lang = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (summary != null) ProjectCard(summary: summary, lang: lang),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('lead.openProject'),
          onPressed: () => context.push(Routes.project(project.id)),
          icon: const Icon(Icons.timeline),
          label: Text(l10n.openProject),
        ),
      ],
    );
  }
}
