import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/powersync/powersync_providers.dart';
import '../l10n/l10n.dart';

/// Shows a clear banner above [child] while sync is configured but the
/// device can't reach the server. Brief drops (app start, reconnects) are
/// ignored: the banner appears after [delay] when a connection attempt
/// failed, or [slowDelay] with no connection at all.
class OfflineAware extends ConsumerStatefulWidget {
  const OfflineAware({
    super.key,
    required this.child,
    this.delay = const Duration(seconds: 4),
    this.slowDelay = const Duration(seconds: 12),
  });

  final Widget child;
  final Duration delay;
  final Duration slowDelay;

  @override
  ConsumerState<OfflineAware> createState() => _OfflineAwareState();
}

class _OfflineAwareState extends ConsumerState<OfflineAware> {
  Timer? _timer;
  bool _show = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Called from build; only the timer callback rebuilds.
  void _update(bool offline, Duration delay) {
    if (!offline) {
      _timer?.cancel();
      _timer = null;
      _show = false; // called from build: no setState needed
    } else if (!_show && _timer == null) {
      _timer = Timer(delay, () {
        if (mounted) setState(() => _show = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(syncStatusProvider).value;
    // Retries flip 'connecting' on and off, so only 'connected' counts.
    final offline = syncConfigured && status != null && !status.connected;
    // Starting up (web especially) can take a few seconds without any
    // error; a failed connection shows the banner sooner.
    _update(
      offline,
      status?.downloadError != null ? widget.delay : widget.slowDelay,
    );
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _show && offline
              ? const _Banner()
              : const SizedBox(width: double.infinity),
        ),
        Expanded(child: widget.child),
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
