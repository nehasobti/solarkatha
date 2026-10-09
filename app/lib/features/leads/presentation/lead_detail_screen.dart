import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../bills/presentation/bill_tab.dart';
import '../../projects/presentation/project_detail_screen.dart';
import '../../proposals/presentation/proposals_tab.dart';
import '../../survey/presentation/survey_tab.dart';
import '../application/leads_providers.dart';
import '../data/leads_repository.dart';
import '../domain/lead.dart';
import 'lead_ui.dart';

/// Lead detail: header with quick actions, then tabs (Overview, Bill, Survey,
/// Proposals, Project). Bill, Survey, Proposals and Project fill in later
/// phases.
class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteLead),
        content: Text(l10n.deleteLeadConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(leadsRepositoryProvider).deleteLead(leadId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.leadDeleted)));
    context.canPop() ? context.pop() : context.go(Routes.leads);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(leadProvider(leadId));
    final lead = async.value;

    if (lead == null) {
      return Scaffold(
        appBar: AppBar(),
        body: async.isLoading
            ? const Center(child: CircularProgressIndicator())
            : EmptyState(
                icon: Icons.person_off_outlined,
                title: l10n.leadNotFound,
              ),
      );
    }

    final pending =
        ref.watch(pendingSyncIdsProvider).value?.contains(lead.id) ?? false;
    final tabs = [
      (l10n.tabOverview, Icons.person_outline),
      (l10n.tabBill, Icons.receipt_long_outlined),
      (l10n.tabSurvey, Icons.roofing_outlined),
      (l10n.tabProposals, Icons.description_outlined),
      (l10n.tabProject, Icons.solar_power_outlined),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 212,
              actions: [
                IconButton(
                  key: const Key('lead.edit'),
                  tooltip: l10n.editLead,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push(Routes.editLead(lead.id)),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') _delete(context, ref);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l10n.deleteLead),
                    ),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _Header(lead: lead, pendingSync: pending),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final (label, icon) in tabs)
                    Tab(icon: Icon(icon, size: 20), text: label),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _Overview(lead: lead),
              BillTab(lead: lead),
              SurveyTab(lead: lead),
              ProposalsTab(lead: lead),
              ProjectTab(leadId: lead.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.lead, required this.pendingSync});

  final Lead lead;
  final bool pendingSync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 56, 16, 72),
        child: Row(
          children: [
            InitialsAvatar(
              name: lead.name,
              color: lead.status.color,
              radius: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusChip(lead.status, dense: true),
                      if (pendingSync)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 14,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              l10n.notSynced,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: l10n.call,
              icon: const Icon(Icons.call),
              onPressed: () => callNumber(lead.phone),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: l10n.whatsapp,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
              ),
              icon: const Icon(Icons.chat),
              onPressed: () => openWhatsApp(lead.phone),
            ),
          ],
        ),
      ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.lead});

  final Lead lead;

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    LeadStatus status,
  ) async {
    String? reason;
    if (status == LeadStatus.lost) {
      final controller = TextEditingController();
      final l10n = context.l10n;
      reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.lostReasonLabel),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 2,
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
      if (reason == null) return;
    }
    await ref
        .read(leadsRepositoryProvider)
        .setStatus(lead.id, status, lostReason: reason);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final team = ref.watch(teamProvider).value ?? const [];
    final assignee = team.where((m) => m.id == lead.assignedTo).firstOrNull;

    Widget row(IconData icon, String label, String? value, {Widget? trailing}) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        title: Text(label, style: theme.textTheme.labelMedium),
        subtitle: Text(value, style: theme.textTheme.bodyLarge),
        trailing: trailing,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.changeStatus, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in LeadStatus.values)
                      ChoiceChip(
                        avatar: Icon(s.icon, size: 18, color: s.color),
                        label: Text(s.label(l10n)),
                        selected: lead.status == s,
                        selectedColor: s.color.withValues(alpha: 0.18),
                        showCheckmark: false,
                        onSelected: lead.status == s
                            ? null
                            : (_) => _changeStatus(context, ref, s),
                      ),
                  ],
                ),
                if (lead.status == LeadStatus.lost &&
                    (lead.lostReason ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('${l10n.lostReasonLabel} ${lead.lostReason}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                row(
                  Icons.phone_outlined,
                  l10n.leadPhoneLabel,
                  '+91 ${lead.phone}',
                ),
                row(
                  Icons.phone_forwarded_outlined,
                  l10n.leadAltPhoneLabel,
                  lead.altPhone == null ? null : '+91 ${lead.altPhone}',
                ),
                row(
                  Icons.place_outlined,
                  l10n.leadAddressLabel,
                  [
                    lead.address,
                    lead.district,
                    lead.stateCode,
                    lead.pincode,
                  ].whereType<String>().where((s) => s.isNotEmpty).join(', '),
                  trailing: lead.hasLocation
                      ? TextButton.icon(
                          onPressed: () => openDirections(lead.lat!, lead.lng!),
                          icon: const Icon(Icons.directions_outlined),
                          label: Text(l10n.directions),
                        )
                      : null,
                ),
                row(
                  Icons.campaign_outlined,
                  l10n.leadSourceLabel,
                  lead.source.label(l10n),
                ),
                row(Icons.badge_outlined, l10n.assignedToLabel, assignee?.name),
                row(
                  Icons.event_outlined,
                  l10n.followUpLabel,
                  lead.nextFollowUpAt == null
                      ? null
                      : formatDay(context, lead.nextFollowUpAt!),
                ),
                row(Icons.notes_outlined, l10n.leadNotesLabel, lead.notes),
                if (lead.createdAt != null)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.history,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      l10n.addedOn(formatDay(context, lead.createdAt!)),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
