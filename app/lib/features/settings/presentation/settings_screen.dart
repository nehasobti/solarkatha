import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../data/powersync/powersync_providers.dart';
import '../../leads/application/leads_providers.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../auth/application/app_session.dart';
import '../../auth/application/session_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final prefs = ref.watch(appPreferencesControllerProvider);
    final prefsCtrl = ref.read(appPreferencesControllerProvider.notifier);
    final session = ref.watch(sessionControllerProvider).value;
    if (session is! Ready) return const SizedBox.shrink();
    final profile = session.profile;

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          header(l10n.profileSection),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(profile.name.isEmpty ? '—' : profile.name),
            subtitle: Text(profile.phone ?? profile.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(l10n.roleLabel),
            trailing: Text(profile.role.label(l10n)),
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: Text(l10n.companyLabel),
            trailing: Text(session.company.name),
          ),
          header(l10n.languageLabel),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: LanguageSwitcher(
                onChanged: (code) => ref
                    .read(profileRepositoryProvider)
                    .updateProfile(profile.id, language: code)
                    .ignore(),
              ),
            ),
          ),
          header(l10n.displaySection),
          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: Text(l10n.highContrast),
            subtitle: Text(l10n.highContrastHint),
            value: prefs.highContrast,
            onChanged: prefsCtrl.setHighContrast,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.format_size),
            title: Text(l10n.largeText),
            subtitle: Text(l10n.largeTextHint),
            value: prefs.largeText,
            onChanged: prefsCtrl.setLargeText,
          ),
          header(l10n.syncSection),
          const _SyncTile(),
          const Divider(height: 32),
          ListTile(
            key: const Key('settings.signOut'),
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              l10n.signOut,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => ref.read(sessionControllerProvider.notifier).signOut(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SyncTile extends ConsumerWidget {
  const _SyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (!syncConfigured) {
      return ListTile(
        leading: const Icon(Icons.phone_android),
        title: Text(l10n.syncNotConfigured),
      );
    }
    final status = ref.watch(syncStatusProvider).value;
    final pending = ref.watch(pendingSyncIdsProvider).value?.length ?? 0;
    final last = status?.lastSyncedAt;
    final online = status?.connected ?? false;
    return ListTile(
      leading: Icon(online ? Icons.cloud_done_outlined : Icons.cloud_off),
      title: Text(online ? l10n.syncStatusOnline : l10n.offline),
      subtitle: Text(
        [
          last == null
              ? l10n.neverSynced
              : l10n.syncedAt(
                  DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                      .add_jm()
                      .format(last.toLocal()),
                ),
          l10n.pendingChanges(pending),
        ].join('\n'),
      ),
      isThreeLine: true,
    );
  }
}
