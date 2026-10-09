import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/presentation/lead_ui.dart';
import '../../projects/data/projects_repository.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_ui.dart';

part 'notifications_screen.g.dart';

@riverpod
Stream<List<AppNotification>> myNotifications(Ref ref) {
  final id = ref.watch(currentMemberProvider)?.profile.id;
  if (id == null) return Stream.value(const []);
  return ref.watch(projectsRepositoryProvider).watchNotifications(id);
}

String notificationText(
  AppLocalizations l10n,
  AppNotification n,
  String lang,
) => switch (n.kind) {
  'project_created' => l10n.notifProjectCreated(
    IndianFormat.kw(
      (n.data['system_kw'] as num?)?.toDouble() ?? 0,
      languageCode: lang,
    ),
  ),
  'stage_done' => l10n.notifStageDone(
    stageLabel(
      l10n,
      StageKind.values.firstWhere(
        (s) => s.dbValue == n.data['stage'],
        orElse: () => StageKind.portalRegistration,
      ),
    ),
  ),
  _ => n.kind,
};

/// App bar bell with the unread count.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = (ref.watch(myNotificationsProvider).value ?? const [])
        .where((n) => n.readAt == null)
        .length;
    return IconButton(
      key: const Key('notifications.bell'),
      tooltip: context.l10n.notificationsTitle,
      onPressed: () => context.push(Routes.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final list = ref.watch(myNotificationsProvider).value ?? const [];
    final me = ref.watch(currentMemberProvider)?.profile.id;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (me != null && list.any((n) => n.readAt == null))
            TextButton(
              onPressed: () =>
                  ref.read(projectsRepositoryProvider).markAllRead(me),
              child: Text(l10n.markAllRead),
            ),
        ],
      ),
      body: list.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none,
              title: l10n.noNotifications,
            )
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = list[i];
                return ListTile(
                  leading: Icon(
                    n.kind == 'stage_done'
                        ? Icons.check_circle_outline
                        : Icons.solar_power_outlined,
                    color: n.readAt == null
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    notificationText(l10n, n, lang),
                    style: TextStyle(
                      fontWeight: n.readAt == null ? FontWeight.w600 : null,
                    ),
                  ),
                  subtitle: n.createdAt == null
                      ? null
                      : Text(formatDay(context, n.createdAt!)),
                  onTap: n.entityId == null
                      ? null
                      : () => context.push(Routes.project(n.entityId!)),
                );
              },
            ),
    );
  }
}
