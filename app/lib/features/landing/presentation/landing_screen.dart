import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_core/solar_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../assistant/presentation/assistant_sheet.dart';
import '../../sizing/domain/sizing_calculator.dart';
import '../../sizing/domain/sizing_config.dart';
import '../data/landing_repository.dart';

const contactEmail = 'info@tychonsoftware.com';

Future<void> _requestAccess() => launchUrl(
  Uri(
    scheme: 'mailto',
    path: contactEmail,
    queryParameters: {'subject': 'SolarKatha access'},
  ),
);

/// Public home page on the web: pitch, features, savings calculator, daily
/// solar news, contact, and the "Ask SolarKatha" assistant.
class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width >= 900 ? 48.0 : 16.0;
    Widget section(Widget child, {Color? color}) => Container(
      width: double.infinity,
      color: color,
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );

    // Browser tab and search-result title.
    return Title(
      title: context.l10n.landingPageTitle,
      color: Brand.orange,
      child: _page(pad, section),
    );
  }

  Widget _page(double pad, Widget Function(Widget, {Color? color}) section) {
    return Builder(builder: (context) => _scaffold(context, pad, section));
  }

  Widget _scaffold(
    BuildContext context,
    double pad,
    Widget Function(Widget, {Color? color}) section,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      floatingActionButton: const AssistantFab(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            titleSpacing: pad,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 32),
                // Very small phones: logo only, so the Login button fits.
                if (width >= 340) ...[
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text('SolarKatha', overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
            actions: [
              FilledButton(
                key: const Key('landing.login'),
                style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
                onPressed: () => context.go(Routes.login),
                child: Text(context.l10n.signInButton),
              ),
              SizedBox(width: pad),
            ],
          ),
          SliverToBoxAdapter(child: _Hero(pad: pad)),
          SliverToBoxAdapter(child: section(const _Features())),
          SliverToBoxAdapter(
            child: section(
              const _Calculator(),
              color: Brand.orangeSoft.withValues(alpha: 0.5),
            ),
          ),
          SliverToBoxAdapter(child: section(const _News())),
          SliverToBoxAdapter(
            child: section(const _Contact(), color: Brand.navy),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.pad});

  final double pad;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    const fg = Colors.white;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const LanguageSwitcher(),
        ),
        const SizedBox(height: 20),
        // Real headings in the HTML: h1 here, h2 for each section.
        Semantics(
          headingLevel: 1,
          child: Text(
            l10n.landingHeadline,
            style:
                (wide
                        ? theme.textTheme.displaySmall
                        : theme.textTheme.headlineMedium)
                    ?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.landingSub,
          style: theme.textTheme.titleMedium?.copyWith(color: fg, height: 1.4),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              key: const Key('landing.requestAccess'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Brand.orange,
              ),
              onPressed: _requestAccess,
              icon: const Icon(Icons.mail_outline),
              label: Text(l10n.requestAccess),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: fg,
                side: const BorderSide(color: fg, width: 1.5),
              ),
              onPressed: () => context.go(Routes.login),
              icon: const Icon(Icons.login),
              label: Text(l10n.signInButton),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.landingAccessNote(contactEmail),
          style: theme.textTheme.bodySmall?.copyWith(
            color: fg.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/landing/dashboard.jpg',
        fit: BoxFit.cover,
        semanticLabel: l10n.landingScreenshotLabel,
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFFC2410C)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: wide ? 64 : 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: wide
              ? Row(
                  children: [
                    Expanded(flex: 5, child: text),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 30,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: image,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [text, const SizedBox(height: 28), image],
                ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, [this.subtitle]);

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            headingLevel: 2,
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = <(IconData, Color, String, String)>[
      (
        Icons.document_scanner_outlined,
        Brand.blue,
        l10n.featBill,
        l10n.landingF1,
      ),
      (Icons.roofing_outlined, Brand.orange, l10n.featRoof, l10n.landingF2),
      (
        Icons.description_outlined,
        Brand.navy,
        l10n.featProposal,
        l10n.landingF3,
      ),
      (Icons.currency_rupee, Brand.green, l10n.featPayments, l10n.landingF4),
      (
        Icons.account_balance_outlined,
        Brand.amber,
        l10n.featSubsidy,
        l10n.landingF5,
      ),
      (Icons.cloud_off_outlined, Brand.blue, l10n.featOffline, l10n.landingF6),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.featuresTitle, l10n.featuresSub),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
            const gap = 16.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final (icon, color, title, body) in items)
                  SizedBox(
                    width: w,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color),
                            ),
                            const SizedBox(height: 14),
                            Text(title, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              body,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Calculator extends ConsumerStatefulWidget {
  const _Calculator();

  @override
  ConsumerState<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends ConsumerState<_Calculator> {
  final _units = TextEditingController(text: '300');
  final _bill = TextEditingController();
  String _state = 'UP';

  @override
  void dispose() {
    _units.dispose();
    _bill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final config = ref.watch(publicSizingConfigProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('calc.units'),
          controller: _units,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.calcUnits,
            suffixText: 'kWh',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bill,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.calcBill,
            prefixText: '₹ ',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'UP', label: Text(l10n.calcStateUP)),
            ButtonSegment(value: 'OTHER', label: Text(l10n.calcStateOther)),
          ],
          selected: {_state},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _state = s.first),
        ),
      ],
    );

    final result = config.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Text(l10n.calcUnavailable),
      data: (c) => _Result(
        config: c,
        units: double.tryParse(_units.text) ?? 0,
        bill: double.tryParse(_bill.text),
        stateCode: _state == 'UP' ? 'UP' : null,
        lang: lang,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.calcTitle, l10n.calcSub),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: form),
                      const SizedBox(width: 32),
                      Expanded(flex: 6, child: result),
                    ],
                  )
                : Column(children: [form, const SizedBox(height: 24), result]),
          ),
        ),
        const SizedBox(height: 10),
        Text(l10n.calcNote, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.config,
    required this.units,
    required this.bill,
    required this.stateCode,
    required this.lang,
  });

  final SizingConfig config;
  final double units;
  final double? bill;
  final String? stateCode;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (units < 30) {
      return Text(l10n.calcNeedUnits, style: theme.textTheme.bodyLarge);
    }
    final calc = SizingCalculator(
      config,
      SizingInputs(
        avgMonthlyUnits: units,
        monthlyPerKw: fallbackMonthlyPerKw(
          config.solar.defaultYieldKwhPerKwDay,
        ),
        stateCode: stateCode,
        billAmount: bill,
      ),
    );
    final kw = math.min(calc.sizing.recommendedKw, 10.0);
    final o = calc.evaluate(kw);
    final saving = o.savings;
    String rs(num v) => IndianFormat.rupees(v.round(), languageCode: lang);
    final tiles = <(String, String, Color)>[
      (l10n.calcSize, IndianFormat.kw(kw, languageCode: lang), Brand.orange),
      (l10n.calcSubsidy, rs(o.subsidy.total), Brand.green),
      (l10n.calcCost, rs(o.netPrice), Brand.navy),
      if (saving != null)
        (l10n.calcSaving, rs(saving.monthlySavingYear1), Brand.green),
      if (saving?.paybackYears case final p?)
        (l10n.calcPayback, l10n.calcYears(p.toStringAsFixed(1)), Brand.blue),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 480 ? 3 : 2;
        const gap = 12.0;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (label, value, color) in tiles)
              Container(
                width: w,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        key: Key('calc.$label'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _News extends ConsumerWidget {
  const _News();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final news = ref.watch(latestNewsProvider(lang));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.newsTitle, l10n.newsSub),
        news.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Text(l10n.newsEmpty),
          data: (items) => items.isEmpty
              ? Text(l10n.newsEmpty)
              : LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth >= 900
                        ? 3
                        : (c.maxWidth >= 560 ? 2 : 1);
                    const gap = 16.0;
                    final w = (c.maxWidth - gap * (cols - 1)) / cols;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final n in items)
                          SizedBox(
                            width: w,
                            child: Card(
                              margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => launchUrl(
                                  Uri.parse(n.url),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        [
                                          ?n.source,
                                          if (n.publishedAt != null)
                                            _ago(l10n, n.publishedAt!),
                                        ].join(' · '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(color: Brand.orange),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        n.title,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(height: 1.35),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            l10n.newsRead,
                                            style: theme.textTheme.labelMedium,
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.open_in_new,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  static String _ago(AppLocalizations l10n, DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inHours < 24) return l10n.newsToday;
    return l10n.newsDaysAgo(d.inDays);
  }
}

class _Contact extends StatelessWidget {
  const _Contact();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    const fg = Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.contactTitle,
          style: theme.textTheme.headlineSmall?.copyWith(color: fg),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.contactBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: fg.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _requestAccess,
              icon: const Icon(Icons.mail_outline),
              label: const Text(contactEmail),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: fg,
                side: const BorderSide(color: fg),
              ),
              onPressed: () => launchUrl(Uri.base.resolve('/solarkatha.apk')),
              icon: const Icon(Icons.android),
              label: Text(l10n.downloadApk),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          l10n.footerCopyright('${DateTime.now().year}'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: fg.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
