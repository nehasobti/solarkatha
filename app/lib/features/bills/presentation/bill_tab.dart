import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/data/leads_repository.dart';
import '../../leads/domain/lead.dart';
import '../application/bills_providers.dart';
import '../data/bills_repository.dart';
import '../domain/bill.dart';

/// Lead detail → Bill tab: scan or type the bill, see queued scans, and jump
/// to sizing once a bill is confirmed.
class BillTab extends ConsumerWidget {
  const BillTab({super.key, required this.lead});

  final Lead lead;

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!lead.hasConsent) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.consentRequiredForPhotos)),
      );
      return;
    }
    final file = await ImagePicker().pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    try {
      final photoId = await ref
          .read(leadsRepositoryProvider)
          .addPhoto(
            lead: lead,
            kind: PhotoKind.bill,
            jpeg: await file.readAsBytes(),
            userId: member.profile.id,
          );
      await ref
          .read(billsRepositoryProvider)
          .queueScan(
            leadId: lead.id,
            companyId: lead.companyId,
            photoId: photoId,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.scanQueued)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bills = ref.watch(leadBillsProvider(lead.id)).value ?? const [];
    final scans = ref.watch(leadScansProvider(lead.id)).value ?? const [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('bill.scan'),
                onPressed: () => _scan(context, ref),
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(l10n.scanBill),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('bill.manual'),
                onPressed: () => context.push(Routes.newBill(lead.id)),
                icon: const Icon(Icons.edit_note),
                label: Text(l10n.enterBillManually),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final job in scans) ...[
          _ScanCard(job: job, leadId: lead.id),
          const SizedBox(height: 8),
        ],
        if (bills.isEmpty && scans.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.noBillsTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(l10n.noBillsBody, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        for (final bill in bills) ...[
          _BillCard(bill: bill),
          const SizedBox(height: 8),
        ],
        if (bills.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.primaryContainer,
            child: ListTile(
              key: const Key('bill.sizing'),
              leading: const Icon(Icons.solar_power),
              title: Text(
                l10n.sizeSystem,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(l10n.sizingCta),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.sizing(lead.id)),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScanCard extends ConsumerWidget {
  const _ScanCard({required this.job, required this.leadId});

  final ScanJob job;
  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final repo = ref.read(billsRepositoryProvider);
    final (icon, color, text) = switch (job.status) {
      ScanStatus.pending => (
        Icons.hourglass_top,
        theme.colorScheme.tertiary,
        l10n.scanQueued,
      ),
      ScanStatus.done => (
        Icons.task_alt,
        const Color(0xFF2E7D32),
        l10n.scanReady,
      ),
      ScanStatus.failed => (
        Icons.error_outline,
        theme.colorScheme.error,
        l10n.scanFailed(job.lastError ?? ''),
      ),
    };
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(child: Text(text)),
              ],
            ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => repo.removeScan(job.id),
                  child: Text(l10n.discardScan),
                ),
                if (job.status == ScanStatus.failed)
                  TextButton(
                    onPressed: () => repo.retryScan(job.id),
                    child: Text(l10n.retry2),
                  ),
                if (job.status == ScanStatus.failed)
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push(Routes.newBill(leadId, scanId: job.id)),
                    child: Text(l10n.enterBillManually),
                  ),
                if (job.status == ScanStatus.done)
                  FilledButton(
                    key: const Key('scan.review'),
                    onPressed: () =>
                        context.push(Routes.newBill(leadId, scanId: job.id)),
                    child: Text(l10n.reviewScan),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(Routes.editBill(bill.leadId, bill.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        bill.discom,
                        bill.consumerNumber,
                      ].whereType<String>().join(' · '),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      bill.source == 'scan'
                          ? Icons.auto_awesome
                          : Icons.edit_note,
                      size: 16,
                    ),
                    label: Text(
                      bill.source == 'scan'
                          ? l10n.billFromScan
                          : l10n.billManual,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (bill.avgMonthlyUnits != null)
                    _Fact(
                      Icons.bolt,
                      l10n.avgUnitsShort(
                        IndianFormat.number(
                          bill.avgMonthlyUnits!,
                          languageCode: lang,
                        ),
                      ),
                    ),
                  if (bill.sanctionedLoadKw != null)
                    _Fact(
                      Icons.electric_meter_outlined,
                      IndianFormat.kw(
                        bill.sanctionedLoadKw!,
                        languageCode: lang,
                      ),
                    ),
                  if (bill.billAmount != null)
                    _Fact(
                      Icons.currency_rupee,
                      IndianFormat.rupees(bill.billAmount!, languageCode: lang),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 4),
      Text(text),
    ],
  );
}
