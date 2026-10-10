import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/project.dart';

String stageLabel(AppLocalizations l10n, StageKind s) => switch (s) {
  StageKind.portalRegistration => l10n.stagePortalRegistration,
  StageKind.discomFeasibility => l10n.stageDiscomFeasibility,
  StageKind.vendorSelected => l10n.stageVendorSelected,
  StageKind.installation => l10n.stageInstallation,
  StageKind.netMeterApplied => l10n.stageNetMeterApplied,
  StageKind.netMeterInstalled => l10n.stageNetMeterInstalled,
  StageKind.inspection => l10n.stageInspection,
  StageKind.commissioningCertificate => l10n.stageCommissioning,
  StageKind.subsidyClaimed => l10n.stageSubsidyClaimed,
  StageKind.subsidyCredited => l10n.stageSubsidyCredited,
};

String stageStatusLabel(AppLocalizations l10n, StageStatus s) => switch (s) {
  StageStatus.pending => l10n.stagePending,
  StageStatus.inProgress => l10n.stageInProgress,
  StageStatus.done => l10n.stageDone,
  StageStatus.blocked => l10n.stageBlocked,
};

Color stageStatusColor(StageStatus s) => switch (s) {
  StageStatus.pending => const Color(0xFF9E9E9E),
  StageStatus.inProgress => const Color(0xFFEA580C),
  StageStatus.done => const Color(0xFF16A34A),
  StageStatus.blocked => const Color(0xFFC62828),
};

IconData stageStatusIcon(StageStatus s) => switch (s) {
  StageStatus.pending => Icons.radio_button_unchecked,
  StageStatus.inProgress => Icons.timelapse,
  StageStatus.done => Icons.check_circle,
  StageStatus.blocked => Icons.block,
};

/// Builds a CSV (Excel-friendly, UTF-8 with BOM) and saves/shares it.
Future<void> exportCsv(
  String fileName,
  List<String> header,
  List<List<Object?>> rows,
) async {
  String cell(Object? v) {
    final s = v?.toString() ?? '';
    return s.contains(RegExp('[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  final csv = [
    header.map(cell).join(','),
    for (final r in rows) r.map(cell).join(','),
  ].join('\r\n');
  final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'text/csv', name: fileName)],
      fileNameOverrides: [fileName],
      downloadFallbackEnabled: true,
    ),
  );
}
