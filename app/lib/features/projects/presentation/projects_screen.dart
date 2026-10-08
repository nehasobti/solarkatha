import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/empty_state.dart';

/// Projects list (installers see assigned projects, owners see all).
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProjects)),
      body: EmptyState(
        icon: Icons.solar_power_outlined,
        title: l10n.projectsEmptyTitle,
        body: l10n.projectsEmptyBody,
      ),
    );
  }
}
