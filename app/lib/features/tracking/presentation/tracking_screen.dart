import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/language_switcher.dart';

/// Public customer tracking page (`/t/<share_token>`), no login. The data is
/// served by the `track` Edge Function in Phase 6.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackingTitle),
        actions: const [LanguageSwitcher(), SizedBox(width: 12)],
      ),
      body: EmptyState(
        icon: Icons.wb_sunny_outlined,
        title: l10n.trackingTitle,
        body: l10n.trackingComingSoon,
      ),
    );
  }
}
