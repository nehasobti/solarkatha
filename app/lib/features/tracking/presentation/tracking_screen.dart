import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../data/supabase/supabase_providers.dart';
import '../../leads/presentation/lead_ui.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_ui.dart';

part 'tracking_screen.g.dart';

/// Talks to the public `track` Edge Function (no login).
class TrackingApi {
  TrackingApi(this._client);

  final SupabaseClient _client;

  /// The page data, or null when the link is unknown or turned off.
  Future<Map<String, dynamic>?> fetch(String token) => _call({'token': token});

  Future<Map<String, dynamic>?> sign(String token, String pngDataUrl) =>
      _call({'token': token, 'action': 'sign', 'signature_png': pngDataUrl});

  Future<Map<String, dynamic>?> _call(Map<String, dynamic> body) async {
    try {
      final res = await _client.functions.invoke('track', body: body);
      final data = res.data;
      return data is Map ? data.cast<String, dynamic>() : null;
    } on FunctionException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }
}

@riverpod
TrackingApi trackingApi(Ref ref) =>
    TrackingApi(ref.watch(supabaseClientProvider));

/// Public customer tracking page (`/t/<share_token>`): proposal summary,
/// PDF, signature, advance payment and the subsidy stages.
class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  late Future<Map<String, dynamic>?> _data = _load();
  String? _lang;

  Future<Map<String, dynamic>?> _load() =>
      ref.read(trackingApiProvider).fetch(widget.token);

  Future<void> _sign(AppLocalizations l10n) async {
    final controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    final png = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.trackSignHint,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
              ),
              child: Signature(
                key: const Key('track.pad'),
                controller: controller,
                height: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: controller.clear,
                  child: Text(l10n.clear),
                ),
                FilledButton(
                  key: const Key('track.submitSignature'),
                  onPressed: () async {
                    if (controller.isEmpty) return;
                    final bytes = await controller.toPngBytes();
                    if (bytes == null || !context.mounted) return;
                    Navigator.pop(
                      context,
                      'data:image/png;base64,${base64Encode(bytes)}',
                    );
                  },
                  child: Text(l10n.trackSubmitSignature),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (png == null) return;
    try {
      final data = await ref.read(trackingApiProvider).sign(widget.token, png);
      setState(() {
        _data = Future.value(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
      setState(() {
        _data = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _data,
      builder: (context, snap) {
        final data = snap.data;
        final lang =
            _lang ??
            (data?['language'] as String?) ??
            Localizations.localeOf(context).languageCode;
        final l10n = lookupAppLocalizations(Locale(lang));
        final brand =
            _hex(data?['company']?['brand_color'] as String?) ??
            const Color(0xFFEA580C);
        return Theme(
          data: Theme.of(context)
              .copyWith(colorScheme: ColorScheme.fromSeed(seedColor: brand)),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              title: Text(
                (data?['company']?['name'] as String?) ?? l10n.trackingTitle,
              ),
              actions: [
                TextButton(
                  key: const Key('track.lang'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () =>
                      setState(() => _lang = lang == 'hi' ? 'en' : 'hi'),
                  child: Text(lang == 'hi' ? 'English' : 'हिंदी'),
                ),
              ],
            ),
            body: switch (snap.connectionState) {
              ConnectionState.waiting => const Center(
                child: CircularProgressIndicator(),
              ),
              _ when snap.hasError => _Message(
                icon: Icons.wifi_off,
                text: '${snap.error}',
                onRetry: () => setState(() {
                  _data = _load();
                }),
              ),
              _ when data == null => _Message(
                icon: Icons.link_off,
                text: l10n.trackNotFound,
              ),
              _ => Localizations.override(
                context: context,
                locale: Locale(lang),
                child: _Content(
                  data: data,
                  l10n: l10n,
                  lang: lang,
                  brand: brand,
                  onSign: () => _sign(l10n),
                ),
              ),
            },
          ),
        );
      },
    );
  }
}

Color? _hex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) return null;
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.black38),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Icon(Icons.refresh),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Content extends StatelessWidget {
  const _Content({
    required this.data,
    required this.l10n,
    required this.lang,
    required this.brand,
    required this.onSign,
  });

  final Map<String, dynamic> data;
  final AppLocalizations l10n;
  final String lang;
  final Color brand;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kw = (data['system_kw'] as num?)?.toDouble() ?? 0;
    final net = (data['net_price'] as num?)?.toDouble();
    final subsidy = (data['subsidy'] as num?)?.toDouble() ?? 0;
    final signed = data['signed'] == true;
    final pdf = data['pdf_url'] as String?;
    final payment = data['payment'] as Map<String, dynamic>?;
    final phone = data['company']?['phone'] as String?;
    final company = (data['company']?['name'] as String?) ?? '';
    final stages = (data['stages'] as List? ?? const [])
        .cast<Map<String, dynamic>>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [brand, Color.lerp(brand, Colors.black, 0.25)!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.trackHello(
                      (data['customer_first_name'] as String?) ?? '',
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.trackSystem(IndianFormat.kw(kw, languageCode: lang)),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (net != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.trackSubsidyLine(
                        IndianFormat.rupees(subsidy, languageCode: lang),
                        IndianFormat.rupees(net, languageCode: lang),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (pdf != null)
              _Action(
                key: const Key('track.pdf'),
                icon: Icons.picture_as_pdf_outlined,
                label: l10n.trackDownloadPdf,
                onTap: () => launchUrl(
                  Uri.parse(pdf),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            if (signed)
              _Done(icon: Icons.verified, text: l10n.trackSigned)
            else
              _Action(
                key: const Key('track.sign'),
                icon: Icons.draw_outlined,
                label: l10n.trackSign,
                filled: true,
                onTap: onSign,
              ),
            if (payment != null)
              payment['status'] == 'paid'
                  ? _Done(icon: Icons.check_circle, text: l10n.trackPaid)
                  : payment['url'] != null
                  ? _Action(
                      key: const Key('track.pay'),
                      icon: Icons.currency_rupee,
                      label: l10n.trackPay(
                        IndianFormat.rupees(
                          (payment['amount'] as num?)?.toDouble() ?? 0,
                          languageCode: lang,
                        ),
                      ),
                      filled: true,
                      onTap: () => launchUrl(
                        Uri.parse(payment['url'] as String),
                        mode: LaunchMode.externalApplication,
                      ),
                    )
                  : const SizedBox.shrink(),
            if (phone != null)
              _Action(
                icon: Icons.call_outlined,
                label: l10n.trackCallCompany(company),
                onTap: () => launchUrl(Uri.parse('tel:$phone')),
              ),
            const SizedBox(height: 20),
            Text(l10n.trackStagesTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (stages.isEmpty)
              Text(l10n.trackNotStarted, style: theme.textTheme.bodyLarge)
            else
              for (final (i, s) in stages.indexed)
                _TimelineRow(
                  stage: s,
                  l10n: l10n,
                  last: i == stages.length - 1,
                ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.titleMedium,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: filled
          ? FilledButton.icon(
              style: style,
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
            )
          : OutlinedButton.icon(
              style: style,
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF16A34A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.stage,
    required this.l10n,
    required this.last,
  });

  final Map<String, dynamic> stage;
  final AppLocalizations l10n;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final kind = StageKind.values
        .where((k) => k.dbValue == stage['stage'])
        .firstOrNull;
    final status =
        StageStatus.values
            .where((s) => s.dbValue == stage['status'])
            .firstOrNull ??
        StageStatus.pending;
    final color = stageStatusColor(status);
    final doneAt = DateTime.tryParse('${stage['done_at']}');
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(stageStatusIcon(status), color: color, size: 22),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kind == null ? '${stage['stage']}' : stageLabel(l10n, kind),
                    style: TextStyle(
                      fontWeight: status == StageStatus.inProgress
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    doneAt != null
                        ? l10n.doneOn(formatDay(context, doneAt.toLocal()))
                        : stageStatusLabel(l10n, status),
                    style: TextStyle(color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
