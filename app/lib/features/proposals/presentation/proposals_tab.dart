import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../leads/domain/lead.dart';
import '../../leads/presentation/lead_ui.dart';
import '../data/proposals_repository.dart';
import '../domain/proposal.dart';

String proposalStatusLabel(AppLocalizations l10n, ProposalStatus s) =>
    switch (s) {
      ProposalStatus.draft => l10n.statusDraft,
      ProposalStatus.sent => l10n.statusSent,
      ProposalStatus.signed => l10n.statusSigned,
      ProposalStatus.expired => l10n.statusExpired,
    };

Color proposalStatusColor(ProposalStatus s) => switch (s) {
  ProposalStatus.draft => const Color(0xFF757575),
  ProposalStatus.sent => const Color(0xFFE07B00),
  ProposalStatus.signed => const Color(0xFF2E7D32),
  ProposalStatus.expired => const Color(0xFFC62828),
};

/// Lead detail → Proposals tab: versions with status, and "New proposal".
class ProposalsTab extends ConsumerWidget {
  const ProposalsTab({super.key, required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final proposals =
        ref.watch(leadProposalsProvider(lead.id)).value ?? const [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          key: const Key('proposals.new'),
          onPressed: () => context.push(Routes.newProposal(lead.id)),
          icon: const Icon(Icons.note_add_outlined),
          label: Text(l10n.newProposal),
        ),
        const SizedBox(height: 16),
        if (proposals.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noProposalsTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.noProposalsBody, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        for (final p in proposals)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              key: Key('proposal.${p.version}'),
              onTap: () => context.push(Routes.proposal(lead.id, p.id)),
              title: Text(
                '${l10n.proposalVersion('${p.version}')} · '
                '${IndianFormat.kw(p.systemKw, languageCode: lang)}',
              ),
              subtitle: Text(
                '${l10n.netPriceShort}: ${IndianFormat.rupees(p.netPrice, languageCode: lang)}'
                '${p.createdAt == null ? '' : ' · ${formatDay(context, p.createdAt!)}'}',
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: proposalStatusColor(p.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  proposalStatusLabel(l10n, p.status),
                  style: TextStyle(
                    color: proposalStatusColor(p.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
