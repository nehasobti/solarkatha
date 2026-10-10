import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/lead.dart';

extension LeadStatusUi on LeadStatus {
  String label(AppLocalizations l10n) => switch (this) {
    LeadStatus.newLead => l10n.statusNew,
    LeadStatus.surveyed => l10n.statusSurveyed,
    LeadStatus.proposalSent => l10n.statusProposalSent,
    LeadStatus.won => l10n.statusWon,
    LeadStatus.lost => l10n.statusLost,
  };

  Color get color => switch (this) {
    LeadStatus.newLead => const Color(0xFF2563EB),
    LeadStatus.surveyed => const Color(0xFF0D9488),
    LeadStatus.proposalSent => const Color(0xFFEA580C),
    LeadStatus.won => const Color(0xFF16A34A),
    LeadStatus.lost => const Color(0xFF94A3B8),
  };

  IconData get icon => switch (this) {
    LeadStatus.newLead => Icons.person_add_alt_outlined,
    LeadStatus.surveyed => Icons.roofing_outlined,
    LeadStatus.proposalSent => Icons.description_outlined,
    LeadStatus.won => Icons.verified_outlined,
    LeadStatus.lost => Icons.do_not_disturb_on_outlined,
  };
}

extension LeadSourceUi on LeadSource {
  String label(AppLocalizations l10n) => switch (this) {
    LeadSource.walkIn => l10n.sourceWalkIn,
    LeadSource.referral => l10n.sourceReferral,
    LeadSource.call => l10n.sourceCall,
    LeadSource.campaign => l10n.sourceCampaign,
  };
}

extension PhotoKindUi on PhotoKind {
  String label(AppLocalizations l10n) => switch (this) {
    PhotoKind.roof => l10n.photoKindRoof,
    PhotoKind.meter => l10n.photoKindMeter,
    PhotoKind.dbBox => l10n.photoKindDbBox,
    PhotoKind.wiringPath => l10n.photoKindWiring,
    PhotoKind.bill => l10n.photoKindBill,
    PhotoKind.other => l10n.photoKindOther,
    PhotoKind.roofLayout => l10n.photoKindRoofLayout,
  };

  IconData get icon => switch (this) {
    PhotoKind.roof => Icons.roofing,
    PhotoKind.meter => Icons.speed,
    PhotoKind.dbBox => Icons.electrical_services,
    PhotoKind.wiringPath => Icons.cable,
    PhotoKind.bill => Icons.receipt_long,
    PhotoKind.other => Icons.photo_camera_outlined,
    PhotoKind.roofLayout => Icons.grid_on,
  };
}

/// Photos the survey checklist asks for (spec: roof, meter, DB box, wiring).
const checklistPhotoKinds = [
  PhotoKind.roof,
  PhotoKind.meter,
  PhotoKind.dbBox,
  PhotoKind.wiringPath,
];

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.dense = false});

  final LeadStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label(context.l10n),
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w600,
          fontSize: dense ? 12 : 13,
        ),
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    required this.color,
    this.radius = 22,
  });

  final String name;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((p) => p.characters.first).join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}

String formatDay(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).languageCode;
  final local = date.toLocal();
  final now = DateTime.now();
  final sameYear = local.year == now.year;
  return DateFormat(sameYear ? 'd MMM' : 'd MMM y', locale).format(local);
}

/// Digits for wa.me / tel: (adds +91 to 10-digit numbers).
String e164(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return digits.length == 10 ? '91$digits' : digits;
}

Future<void> callNumber(String phone) =>
    launchUrl(Uri(scheme: 'tel', path: '+${e164(phone)}'));

Future<void> openWhatsApp(String phone, {String text = ''}) => launchUrl(
  Uri.https('wa.me', '/${e164(phone)}', text.isEmpty ? null : {'text': text}),
  mode: LaunchMode.externalApplication,
);

Future<void> openDirections(double lat, double lng) => launchUrl(
  Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '$lat,$lng',
  }),
  mode: LaunchMode.externalApplication,
);
