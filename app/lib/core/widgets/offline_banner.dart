import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/powersync/powersync_providers.dart';
import '../l10n/l10n.dart';

/// Shows a clear banner above [child] while sync is configured but the
/// device can't reach the server.
class OfflineAware extends ConsumerWidget {
  const OfflineAware({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    final offline =
        syncConfigured &&
        status != null &&
        !status.connected &&
        !status.connecting;
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: offline
              ? const _Banner()
              : const SizedBox(width: double.infinity),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.inverseSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: theme.colorScheme.onInverseSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.offlineBanner,
                  style: TextStyle(color: theme.colorScheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small status pill: online / syncing / offline, with pending uploads.
class SyncChip extends ConsumerWidget {
  const SyncChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value;
    final (icon, label) = !syncConfigured
        ? (Icons.phone_android, l10n.offline)
        : status == null || (!status.connected && !status.connecting)
        ? (Icons.cloud_off, l10n.offline)
        : status.uploading || status.downloading || status.connecting
        ? (Icons.sync, l10n.syncing)
        : (Icons.cloud_done_outlined, l10n.online);
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
