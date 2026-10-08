import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/session_controller.dart';

class DeactivatedScreen extends ConsumerWidget {
  const DeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      body: EmptyState(
        icon: Icons.block_outlined,
        title: l10n.deactivatedTitle,
        body: l10n.deactivatedBody,
        action: FilledButton(
          onPressed: () =>
              ref.read(sessionControllerProvider.notifier).signOut(),
          child: Text(l10n.signOut),
        ),
      ),
    );
  }
}
