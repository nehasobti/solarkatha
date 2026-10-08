import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/session_controller.dart';

/// Shown while the session is being resolved, or when that failed.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);

    if (session.hasError && !session.isLoading) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: describeError(l10n, session.error!),
          action: Wrap(
            spacing: 12,
            children: [
              FilledButton(
                onPressed: () => ref.invalidate(sessionControllerProvider),
                child: Text(l10n.retry),
              ),
              OutlinedButton(
                onPressed: () =>
                    ref.read(sessionControllerProvider.notifier).signOut(),
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wb_sunny,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(l10n.loading),
          ],
        ),
      ),
    );
  }
}
