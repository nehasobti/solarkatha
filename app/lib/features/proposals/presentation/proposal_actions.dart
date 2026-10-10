import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../leads/domain/lead.dart';
import '../../leads/presentation/lead_ui.dart';
import '../data/proposals_repository.dart';
import '../domain/proposal.dart';

/// PDF, WhatsApp, signature and payment link for a saved proposal.
class ProposalActions extends ConsumerStatefulWidget {
  const ProposalActions({
    super.key,
    required this.proposal,
    required this.lead,
    required this.companyName,
    required this.canSend,
  });

  final Proposal proposal;
  final Lead lead;
  final String companyName;

  /// Compliance passed (or owner override).
  final bool canSend;

  @override
  ConsumerState<ProposalActions> createState() => _ProposalActionsState();
}

class _ProposalActionsState extends ConsumerState<ProposalActions> {
  String? _pdfUrl;
  bool _busy = false;
  late final _advance = TextEditingController();
  bool _advanceLoaded = false;

  Proposal get p => widget.proposal;
  ProposalsRepository get _repo => ref.read(proposalsRepositoryProvider);

  @override
  void dispose() {
    _advance.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_advanceLoaded) {
      _advanceLoaded = true;
      _repo.configValue('advance_pct', p.companyId).then((pct) {
        final percent = pct is num ? pct.toDouble() : 0.0;
        if (mounted && percent > 0) {
          _advance.text = (p.netPrice * percent / 100).round().toString();
        }
      });
    }
  }

  Future<void> _guard(Future<void> Function() action) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } on ServerStepException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Returns a fresh PDF link, generating it on the server if needed.
  Future<String?> _ensurePdf({bool force = false}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!force && _pdfUrl != null && !p.pdfStale) return _pdfUrl;
    if (await _repo.hasPendingUpload(p.id)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.waitingToSync)));
      return null;
    }
    final url = await _repo.requestPdf(p.id);
    if (mounted) setState(() => _pdfUrl = url);
    return url;
  }

  Future<String> _template(String key, Map<String, String> values) async {
    final t = await _repo.configValue('${key}_${p.language}', p.companyId);
    return fillTemplate(t is String ? t : '', values);
  }

  Future<void> _sendWhatsApp() => _guard(() async {
    final url = await _ensurePdf();
    if (url == null) return;
    final lang = p.language;
    final text = await _template('wa_template_proposal', {
      'customer_name': widget.lead.name,
      'company_name': widget.companyName,
      'system_kw': IndianFormat.kw(p.systemKw, languageCode: lang),
      'net_price': IndianFormat.rupees(p.netPrice, languageCode: lang),
      'pdf_link': url,
    });
    await openWhatsApp(widget.lead.phone, text: text);
    await _repo.markSent(p);
  });

  Future<void> _sharePdfFile() => _guard(() async {
    final url = await _ensurePdf();
    if (url == null || p.pdfPath == null && _pdfUrl == null) return;
    if (kIsWeb) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }
    final fresh = ref.read(proposalProvider(p.id)).value ?? p;
    final bytes = await _repo.downloadPdf(fresh.pdfPath!);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/proposal-${widget.lead.name.replaceAll(RegExp(r'\W+'), '-')}-v${p.version}.pdf',
    );
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]),
    );
    await _repo.markSent(p);
  });

  Future<void> _sign() async {
    final l10n = context.l10n;
    final controller = SignatureController(
      penStrokeWidth: 3,
      exportBackgroundColor: Colors.white,
    );
    final png = await showDialog<Uint8List>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.captureSignature),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.signHereHint),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                ),
                child: Signature(
                  key: const Key('signature.pad'),
                  controller: controller,
                  height: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.clear,
            child: Text(l10n.clearSignature),
          ),
          FilledButton(
            key: const Key('signature.save'),
            onPressed: () async {
              if (controller.isEmpty) return;
              final bytes = await controller.toPngBytes(
                height: 200,
                width: 420,
              );
              if (context.mounted) Navigator.pop(context, bytes);
            },
            child: Text(l10n.saveSignature),
          ),
        ],
      ),
    );
    controller.dispose();
    if (png != null) await _repo.sign(p, png);
  }

  Future<void> _createPaymentLink() => _guard(() async {
    final amount = double.tryParse(_advance.text);
    if (await _repo.hasPendingUpload(p.id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.waitingToSync)));
      return;
    }
    final (url, value) = await _repo.createPaymentLink(p.id, amount: amount);
    await _sendPaymentLink(url, value);
  });

  Future<void> _sendPaymentLink(String url, double amount) async {
    final text = await _template('wa_template_payment', {
      'customer_name': widget.lead.name,
      'amount': IndianFormat.rupees(amount, languageCode: p.language),
      'payment_link': url,
    });
    await openWhatsApp(widget.lead.phone, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final payments =
        ref.watch(proposalPaymentsProvider(p.id)).value ?? const [];
    final hasPdf = p.pdfPath != null && !p.pdfStale;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.actionsSection, style: theme.textTheme.titleMedium),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            if (!widget.canSend) ...[
              Text(
                l10n.complianceBlocked,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 8),
            ],
            // 1. PDF + WhatsApp
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('proposal.pdf'),
                  onPressed: _busy || !widget.canSend
                      ? null
                      : () => _guard(() async {
                          await _ensurePdf(force: true);
                        }),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(hasPdf ? l10n.regeneratePdf : l10n.generatePdf),
                ),
                FilledButton.icon(
                  key: const Key('proposal.whatsapp'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                  ),
                  onPressed: _busy || !widget.canSend ? null : _sendWhatsApp,
                  icon: const Icon(Icons.chat),
                  label: Text(l10n.shareWhatsapp),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || !widget.canSend ? null : _sharePdfFile,
                  icon: const Icon(Icons.share_outlined),
                  label: Text(l10n.sharePdf),
                ),
              ],
            ),
            if (_pdfUrl != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF16A34A),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(l10n.pdfReady),
                  const Spacer(),
                  TextButton(
                    onPressed: () => launchUrl(
                      Uri.parse(_pdfUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(l10n.openPdf),
                  ),
                ],
              ),
            ],
            const Divider(height: 32),
            // 2. Signature
            if (p.signaturePng != null) ...[
              Text(
                l10n.signedOnDate(
                  p.signedAt == null ? '' : formatDay(context, p.signedAt!),
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 90,
                alignment: Alignment.centerLeft,
                child: Image.memory(
                  UriData.parse(p.signaturePng!).contentAsBytes(),
                  fit: BoxFit.contain,
                ),
              ),
            ] else
              OutlinedButton.icon(
                key: const Key('proposal.sign'),
                onPressed: _busy || !widget.canSend ? null : _sign,
                icon: const Icon(Icons.draw_outlined),
                label: Text(l10n.captureSignature),
              ),
            const Divider(height: 32),
            // 3. Advance payment
            Text(l10n.paymentSection, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              key: const Key('proposal.advance'),
              controller: _advance,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.advanceAmount,
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              key: const Key('proposal.paymentLink'),
              onPressed: _busy || !widget.canSend ? null : _createPaymentLink,
              icon: const Icon(Icons.currency_rupee),
              label: Text(l10n.createPaymentLink),
            ),
            for (final pay in payments) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  pay.status == PaymentStatus.paid
                      ? Icons.verified
                      : Icons.schedule,
                  color: pay.status == PaymentStatus.paid
                      ? const Color(0xFF16A34A)
                      : theme.colorScheme.tertiary,
                ),
                title: Text(
                  IndianFormat.rupees(pay.amount, languageCode: lang),
                ),
                subtitle: Text(switch (pay.status) {
                  PaymentStatus.paid => l10n.paymentPaid,
                  PaymentStatus.created => l10n.paymentWaiting,
                  _ => l10n.paymentExpired,
                }),
                trailing:
                    pay.status == PaymentStatus.created && pay.shortUrl != null
                    ? Wrap(
                        children: [
                          IconButton(
                            tooltip: l10n.copyLink,
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: pay.shortUrl!),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.linkCopied)),
                                );
                              }
                            },
                          ),
                          IconButton(
                            tooltip: l10n.sendPaymentLink,
                            color: const Color(0xFF25D366),
                            icon: const Icon(Icons.chat),
                            onPressed: () =>
                                _sendPaymentLink(pay.shortUrl!, pay.amount),
                          ),
                        ],
                      )
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
