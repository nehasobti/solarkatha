import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/empty_state.dart';

/// Owner sections that are built in later phases (subsidy tracker, team,
/// products, config, branding).
class SectionPlaceholderScreen extends StatelessWidget {
  const SectionPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String Function(AppLocalizations) title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(title(l10n))),
      body: EmptyState(icon: icon, title: title(l10n), body: l10n.comingSoon),
    );
  }
}
