import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../leads/domain/lead.dart';
import '../../leads/presentation/lead_photos_section.dart';
import '../data/survey_repository.dart';
import '../domain/site.dart';
import 'survey_screen.dart' show directionLabel;

String roofTypeLabel(AppLocalizations l10n, RoofType t) => switch (t) {
  RoofType.rcc => l10n.roofRcc,
  RoofType.tinSheet => l10n.roofTin,
  RoofType.other => l10n.roofOther,
};

/// Lead detail → Survey tab: survey summary, button to (re)draw the roof,
/// and the site photo checklist.
class SurveyTab extends ConsumerWidget {
  const SurveyTab({super.key, required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final site = ref.watch(leadSiteProvider(lead.id)).value;

    Widget fact(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.roofing, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.surveyTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (site == null)
                  Text(l10n.noSurveyBody)
                else ...[
                  if (site.maxKw != null)
                    Text(
                      l10n.maxKwRoof(
                        IndianFormat.kw(site.maxKw!, languageCode: lang),
                      ),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (site.usableAreaSqm != null)
                    fact(
                      l10n.roofAreaResult,
                      '${IndianFormat.number(site.usableAreaSqm!.round(), languageCode: lang)} m²',
                    ),
                  if (site.fittedPanelCount != null)
                    fact(l10n.panelsFit, '${site.fittedPanelCount}'),
                  if (site.roofType != null)
                    fact(
                      l10n.roofTypeLabel,
                      roofTypeLabel(l10n, site.roofType!),
                    ),
                  fact(
                    l10n.orientationLabel,
                    directionLabel(l10n, site.orientationDeg),
                  ),
                  if (site.tiltDeg != null)
                    fact(l10n.tiltLabel, l10n.degreesValue('${site.tiltDeg}')),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('survey.open'),
                  onPressed: () => context.push(Routes.survey(lead.id)),
                  icon: const Icon(Icons.satellite_alt_outlined),
                  label: Text(
                    site == null ? l10n.startSurvey : l10n.editSurvey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        LeadPhotosSection(lead: lead),
        const SizedBox(height: 32),
      ],
    );
  }
}
