import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/user_role.dart';
import '../application/leads_providers.dart';
import '../data/leads_repository.dart';
import '../domain/lead.dart';
import 'lead_card.dart';
import 'lead_ui.dart';

/// Leads list: search, status filter (with counts), rep filter for owners,
/// call/WhatsApp on each card. Works fully offline.
class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  final _search = TextEditingController();
  String _query = '';
  LeadStatus? _status;
  String? _rep;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final member = ref.watch(currentMemberProvider);
    final isOwner = member?.profile.role == UserRole.owner;
    final filter = LeadFilter(query: _query, status: _status, assignedTo: _rep);
    final leads = ref.watch(leadListProvider(filter));
    final counts = ref.watch(leadStatusCountsProvider).value ?? const {};
    final pending = ref.watch(pendingSyncIdsProvider).value ?? const {};
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navLeads)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('leads.new'),
        onPressed: () => context.push(Routes.newLead),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.newLead),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.searchLeads,
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _search.clear();
                                _query = '';
                              }),
                            ),
                    ),
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 12),
                  _RepFilter(
                    value: _rep,
                    onChanged: (v) => setState(() => _rep = v),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: '${l10n.allStatuses} · $total',
                  selected: _status == null,
                  onTap: () => setState(() => _status = null),
                ),
                for (final s in LeadStatus.values)
                  _FilterChip(
                    label: '${s.label(l10n)} · ${counts[s] ?? 0}',
                    color: s.color,
                    selected: _status == s,
                    onTap: () =>
                        setState(() => _status = _status == s ? null : s),
                  ),
              ],
            ),
          ),
          Expanded(
            child: leads.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(describeError(l10n, e))),
              data: (list) {
                if (list.isEmpty) {
                  final filtered = _query.isNotEmpty || _status != null;
                  return EmptyState(
                    icon: filtered ? Icons.search_off : Icons.people_outline,
                    title: filtered ? l10n.noResults : l10n.leadsEmptyTitle,
                    body: filtered ? null : l10n.leadsEmptyBody,
                  );
                }
                Widget card(Lead lead) => LeadCard(
                  key: ValueKey(lead.id),
                  lead: lead,
                  pendingSync: pending.contains(lead.id),
                  onTap: () => context.push(Routes.lead(lead.id)),
                );
                const pad = EdgeInsets.fromLTRB(16, 4, 16, 96);
                if (wide) {
                  return GridView.builder(
                    padding: pad,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 480,
                          mainAxisExtent: 104,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => card(list[i]),
                  );
                }
                return ListView.separated(
                  padding: pad,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => card(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: (color ?? Theme.of(context).colorScheme.primary)
            .withValues(alpha: 0.18),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _RepFilter extends ConsumerWidget {
  const _RepFilter({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final team = ref.watch(teamProvider).value ?? const [];
    return DropdownButton<String?>(
      value: value,
      underline: const SizedBox.shrink(),
      hint: Text(l10n.allReps),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.allReps)),
        for (final m in team)
          DropdownMenuItem(value: m.id, child: Text(m.name)),
      ],
      onChanged: onChanged,
    );
  }
}
