import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../leads/application/leads_providers.dart';
import '../data/admin_repository.dart';

String roleLabel(AppLocalizations l10n, String role) => switch (role) {
  'owner' => l10n.roleOwner,
  'sales' => l10n.roleSales,
  'installer' => l10n.roleInstaller,
  _ => role,
};

/// Team: members with their numbers, activate/deactivate, phone invites.
class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  late Future<List<Invite>> _invites = _load();

  Future<List<Invite>> _load() async {
    final company = ref.read(currentMemberProvider)?.company.id;
    if (company == null) return const [];
    try {
      return await ref.read(adminRepositoryProvider).invites(company);
    } catch (_) {
      return const []; // offline
    }
  }

  void _reload() => setState(() => _invites = _load());

  Future<void> _invite() async {
    final l10n = context.l10n;
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    final name = TextEditingController();
    final phone = TextEditingController();
    var role = 'sales';
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(l10n.inviteMember),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('invite.name'),
                  controller: name,
                  decoration: InputDecoration(labelText: l10n.nameLabel),
                ),
                TextFormField(
                  key: const Key('invite.phone'),
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.phoneLabel,
                    prefixText: '+91 ',
                  ),
                  validator: (v) =>
                      (v ?? '').length == 10 ? null : l10n.invalidPhone,
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'sales', label: Text(l10n.roleSales)),
                    ButtonSegment(
                      value: 'installer',
                      label: Text(l10n.roleInstaller),
                    ),
                  ],
                  selected: {role},
                  onSelectionChanged: (v) => setLocal(() => role = v.first),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              key: const Key('invite.save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .invite(
              companyId: member.company.id,
              invitedBy: member.profile.id,
              name: name.text.trim(),
              phone: '91${phone.text}',
              role: role,
            );
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.inviteSent)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$e')));
        }
      }
      _reload();
    }
    name.dispose();
    phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final me = ref.watch(currentMemberProvider)?.profile.id;
    final members = ref.watch(membersProvider).value ?? const <Member>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTeam)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('team.invite'),
        onPressed: _invite,
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.inviteMember),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          for (final m in members)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: m.active
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        m.name.isEmpty ? '?' : m.name[0].toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.id == me
                                ? '${m.name} (${l10n.youLabel})'
                                : m.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: m.active
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            [
                              roleLabel(l10n, m.role),
                              if (!m.active) l10n.inactiveLabel,
                              ?m.phone,
                            ].join(' · '),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.leadsCountLabel}: ${m.leads} · '
                            '${l10n.wonCountLabel}: ${m.won} · '
                            '${IndianFormat.kw(m.kw, languageCode: lang)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (m.id != me && m.role != 'owner')
                      TextButton(
                        onPressed: () => ref
                            .read(adminRepositoryProvider)
                            .setActive(m.id, !m.active),
                        child: Text(m.active ? l10n.deactivate : l10n.activate),
                      ),
                  ],
                ),
              ),
            ),
          FutureBuilder<List<Invite>>(
            future: _invites,
            builder: (context, snap) {
              final invites = snap.data ?? const <Invite>[];
              if (invites.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(l10n.pendingInvites, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final i in invites)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.hourglass_empty),
                        title: Text(
                          (i.name ?? '').isNotEmpty ? i.name! : (i.phone ?? ''),
                        ),
                        subtitle: Text(
                          '${roleLabel(l10n, i.role)} · +${i.phone ?? ''}',
                        ),
                        trailing: IconButton(
                          tooltip: l10n.cancelInvite,
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            await ref
                                .read(adminRepositoryProvider)
                                .revokeInvite(i.id);
                            _reload();
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
