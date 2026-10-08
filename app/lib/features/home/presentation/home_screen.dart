import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/domain/lead.dart';
import '../../leads/presentation/lead_card.dart';
import '../../leads/presentation/lead_ui.dart';

/// Sales rep home: big "New lead" button, counts by status, today's
/// follow-ups.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final member = ref.watch(currentMemberProvider);
    final counts = ref.watch(leadStatusCountsProvider).value ?? const {};
    final followUps = ref.watch(todaysFollowUpsProvider);
    final pending = ref.watch(pendingSyncIdsProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.greeting(member?.profile.name ?? '')),
        actions: const [SyncChip(), SizedBox(width: 12)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              key: const Key('home.newLead'),
              onPressed: () => context.push(Routes.newLead),
              icon: const Icon(Icons.person_add_alt_1, size: 28),
              label: Text(l10n.newLead, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.leadsByStatus, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 100,
            ),
            children: [
              for (final s in LeadStatus.values)
                _StatusTile(status: s, count: counts[s] ?? 0),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.followUpsToday, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          followUps.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(describeError(l10n, e)),
            data: (list) => list.isEmpty
                ? Card(
                    margin: EdgeInsets.zero,
                    child: SizedBox(
                      height: 160,
                      child: EmptyState(
                        icon: Icons.event_available_outlined,
                        title: l10n.noFollowUps,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final lead in list) ...[
                        LeadCard(
                          lead: lead,
                          pendingSync: pending.contains(lead.id),
                          onTap: () => context.push(Routes.lead(lead.id)),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.status, required this.count});

  final LeadStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: status.color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(Routes.leads),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(status.icon, color: status.color, size: 20),
              Text(
                '$count',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                status.label(context.l10n),
                style: theme.textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
