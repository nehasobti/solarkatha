import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/lead.dart';
import 'lead_ui.dart';

/// One lead in a list: who, where, status, follow-up, and one-tap call /
/// WhatsApp.
class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
    this.pendingSync = false,
  });

  final Lead lead;
  final VoidCallback onTap;
  final bool pendingSync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final followUp = lead.nextFollowUpAt;
    final overdue =
        followUp != null &&
        lead.status.isOpen &&
        followUp.isBefore(DateTime.now());

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              InitialsAvatar(name: lead.name, color: lead.status.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            lead.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pendingSync) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: l10n.notSynced,
                            child: Icon(
                              Icons.cloud_upload_outlined,
                              size: 16,
                              color: theme.colorScheme.tertiary,
                              semanticLabel: l10n.notSynced,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        lead.phone,
                        if (lead.shortAddress.isNotEmpty) lead.shortAddress,
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(lead.status, dense: true),
                        if (followUp != null && lead.status.isOpen)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 14,
                                color: overdue
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                overdue
                                    ? l10n.overdue
                                    : formatDay(context, followUp),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: overdue
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.call,
                icon: const Icon(Icons.call_outlined),
                onPressed: () => callNumber(lead.phone),
              ),
              IconButton(
                tooltip: l10n.whatsapp,
                icon: const Icon(Icons.chat_outlined),
                color: const Color(0xFF25D366),
                onPressed: () => openWhatsApp(lead.phone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
