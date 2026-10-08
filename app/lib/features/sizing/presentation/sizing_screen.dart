import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:solar_core/solar_core.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../bills/application/bills_providers.dart';
import '../../bills/domain/bill.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/domain/lead.dart';
import '../data/sizing_repository.dart';
import '../domain/sizing_calculator.dart';
import '../domain/sizing_config.dart';

/// Recommended kW with 2 kW / 3 kW / custom options, monthly generation,
/// subsidy, net cost, EMI vs current bill, and payback. Works offline.
class SizingScreen extends ConsumerWidget {
  const SizingScreen({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lead = ref.watch(leadProvider(leadId)).value;
    final bills = ref.watch(leadBillsProvider(leadId));
    final config = ref.watch(sizingConfigProvider);

    Widget body;
    if (lead == null || !bills.hasValue || config.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (config.value == null) {
      body = EmptyState(
        icon: Icons.cloud_sync_outlined,
        title: l10n.configMissing,
      );
    } else {
      body = _SizingBody(
        lead: lead,
        bill: bills.value!.firstOrNull,
        config: config.value!,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lead == null
              ? l10n.sizingTitle
              : '${l10n.sizingTitle} · ${lead.name}',
        ),
      ),
      body: body,
    );
  }
}

class _SizingBody extends ConsumerStatefulWidget {
  const _SizingBody({
    required this.lead,
    required this.bill,
    required this.config,
  });

  final Lead lead;
  final Bill? bill;
  final SizingConfig config;

  @override
  ConsumerState<_SizingBody> createState() => _SizingBodyState();
}

class _SizingBodyState extends ConsumerState<_SizingBody> {
  late final _avg = TextEditingController(
    text: _n(widget.bill?.avgMonthlyUnits),
  );
  late final _load = TextEditingController(
    text: _n(widget.bill?.sanctionedLoadKw),
  );
  final _roof = TextEditingController();
  late final _price = TextEditingController(
    text: _n(widget.config.solar.pricePerKw),
  );
  late final _rate = TextEditingController(
    text: _n(widget.config.loans.firstOrNull?.ratePct),
  );

  ShadingLevel _shading = ShadingLevel.none;
  bool _eligible = true;
  double? _selectedKw;
  bool _custom = false;
  String? _loanId;
  int? _years;
  GenerationEstimate? _generation;

  static String _n(double? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  static double? _parse(String s) =>
      double.tryParse(s.replaceAll(',', '').trim());

  @override
  void initState() {
    super.initState();
    _loanId = widget.config.loans.firstOrNull?.id;
    _years = widget.config.loans.firstOrNull?.maxYears;
    ref
        .read(generationServiceProvider)
        .estimate(
          lat: widget.lead.lat,
          lng: widget.lead.lng,
          config: widget.config.solar,
        )
        .then((g) {
          if (mounted) setState(() => _generation = g);
        });
  }

  @override
  void dispose() {
    for (final c in [_avg, _load, _roof, _price, _rate]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final generation =
        _generation ??
        GenerationEstimate(
          fallbackMonthlyPerKw(widget.config.solar.defaultYieldKwhPerKwDay),
          fromPvgis: false,
        );
    final avg = _parse(_avg.text) ?? 0;

    final calc = SizingCalculator(
      widget.config,
      SizingInputs(
        avgMonthlyUnits: avg,
        monthlyPerKw: generation.monthlyPerKw,
        history12: widget.bill?.history12,
        sanctionedLoadKw: _parse(_load.text),
        roofAreaSqm: _parse(_roof.text),
        shading: _shading,
        panelsEligible: _eligible,
        stateCode: widget.lead.stateCode,
        discom: widget.bill?.discom,
        billAmount: widget.bill?.billAmount,
        pricePerKw: _parse(_price.text),
        loanRatePct: _parse(_rate.text),
        loanYears: _years,
      ),
    );
    final sizing = calc.sizing;
    final selected = _selectedKw ?? sizing.recommendedKw;
    final option = selected > 0 ? calc.evaluate(selected) : null;
    String rupees(num v) => IndianFormat.rupees(v, languageCode: lang);
    String kw(num v) => IndianFormat.kw(v, languageCode: lang);

    final numeric = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    void changed() => setState(() {});

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: l10n.usageSection,
              icon: Icons.bolt,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('sizing.avg'),
                        controller: _avg,
                        keyboardType: TextInputType.number,
                        inputFormatters: numeric,
                        decoration: InputDecoration(
                          labelText: l10n.avgUnitsLabel,
                        ),
                        onChanged: (_) => setState(() => _selectedKw = null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _load,
                        keyboardType: TextInputType.number,
                        inputFormatters: numeric,
                        decoration: InputDecoration(
                          labelText: l10n.sanctionedLoadLabel,
                        ),
                        onChanged: (_) => changed(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _roof,
                        keyboardType: TextInputType.number,
                        inputFormatters: numeric,
                        decoration: InputDecoration(
                          labelText: l10n.roofAreaLabel,
                        ),
                        onChanged: (_) => setState(() => _selectedKw = null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<ShadingLevel>(
                        isExpanded: true,
                        initialValue: _shading,
                        decoration: InputDecoration(
                          labelText: l10n.shadingLabel,
                        ),
                        items: [
                          for (final s in ShadingLevel.values)
                            DropdownMenuItem(
                              value: s,
                              child: Text(switch (s) {
                                ShadingLevel.none => l10n.shadingNone,
                                ShadingLevel.low => l10n.shadingLow,
                                ShadingLevel.medium => l10n.shadingMedium,
                                ShadingLevel.high => l10n.shadingHigh,
                              }),
                            ),
                        ],
                        onChanged: (v) => setState(() => _shading = v!),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  key: const Key('sizing.dcr'),
                  contentPadding: EdgeInsets.zero,
                  value: _eligible,
                  title: Text(l10n.dcrPanels),
                  subtitle: Text(l10n.dcrHint),
                  onChanged: (v) => setState(() => _eligible = v),
                ),
              ],
            ),
            if (avg <= 0)
              _Notice(icon: Icons.info_outline, text: l10n.needUsage)
            else ...[
              _RecommendationCard(
                sizing: sizing,
                selected: selected,
                custom: _custom,
                kwLabel: kw,
                avgUnits: IndianFormat.number(avg, languageCode: lang),
                loadLabel: _load.text.trim(),
                onSelect: (v, {custom = false}) => setState(() {
                  _selectedKw = v;
                  _custom = custom;
                }),
              ),
              if (sizing.options.length > 1)
                _CompareTable(calc: calc, options: sizing.options, lang: lang),
              if (option != null) ...[
                _Section(
                  title: l10n.generationTitle,
                  icon: Icons.wb_sunny_outlined,
                  children: [
                    Text(
                      l10n.perYear(
                        IndianFormat.number(
                          option.annualKwh.round(),
                          languageCode: lang,
                        ),
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(
                      height: 180,
                      child: _GenerationChart(
                        generation: option.generation,
                        usage: calc.usage,
                      ),
                    ),
                    Text(
                      generation.fromPvgis
                          ? l10n.generationPvgis
                          : l10n.generationFallback(
                              _n(widget.config.solar.defaultYieldKwhPerKwDay),
                            ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                _SubsidyCard(option: option, rupees: rupees, kw: kw),
                _Section(
                  title: l10n.costSection,
                  icon: Icons.currency_rupee,
                  children: [
                    TextField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      inputFormatters: numeric,
                      decoration: InputDecoration(
                        labelText: l10n.pricePerKwLabel,
                      ),
                      onChanged: (_) => changed(),
                    ),
                    _Line(l10n.grossPrice, rupees(option.grossPrice)),
                    _Line(
                      l10n.totalSubsidy,
                      '− ${rupees(option.subsidy.total)}',
                    ),
                    _Line(
                      l10n.netPrice,
                      rupees(option.netPrice),
                      bold: true,
                      valueKey: const Key('sizing.net'),
                    ),
                  ],
                ),
                _Section(
                  title: l10n.loanSection,
                  icon: Icons.account_balance_outlined,
                  children: [
                    if (widget.config.loans.isNotEmpty)
                      DropdownButtonFormField<String>(
                        initialValue: _loanId,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l10n.loanBank),
                        items: [
                          for (final p in widget.config.loans)
                            DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                '${p.bankName} · ${_n(p.ratePct)}%',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (id) => setState(() {
                          final p = widget.config.loans.firstWhere(
                            (l) => l.id == id,
                          );
                          _loanId = id;
                          _rate.text = _n(p.ratePct);
                          _years = p.maxYears;
                        }),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rate,
                            keyboardType: TextInputType.number,
                            inputFormatters: numeric,
                            decoration: InputDecoration(
                              labelText: l10n.interestRate,
                            ),
                            onChanged: (_) => changed(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            isExpanded: true,
                            initialValue: calc.loanYears,
                            decoration: InputDecoration(
                              labelText: l10n.tenureYears,
                            ),
                            items: [
                              for (var y = 1; y <= 15; y++)
                                DropdownMenuItem(value: y, child: Text('$y')),
                            ],
                            onChanged: (v) => setState(() => _years = v),
                          ),
                        ),
                      ],
                    ),
                    _EmiVsBill(
                      emi: option.loan.emi,
                      bill: calc.currentMonthlyBill,
                      rupees: rupees,
                    ),
                  ],
                ),
                _SavingsCard(calc: calc, option: option, rupees: rupees),
                FilledButton.icon(
                  key: const Key('sizing.createProposal'),
                  onPressed: () => context.push(
                    '${Routes.newProposal(widget.lead.id)}?kw=$selected',
                  ),
                  icon: const Icon(Icons.note_add_outlined),
                  label: Text(l10n.createProposal),
                ),
              ],
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children.expand((w) => [w, const SizedBox(height: 10)]).toList()
              ..removeLast(),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.tertiary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.bold = false, this.valueKey});

  final String label;
  final String value;
  final bool bold;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, key: valueKey, style: style),
      ],
    );
  }
}

typedef _Fmt = String Function(num v);

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.sizing,
    required this.selected,
    required this.custom,
    required this.kwLabel,
    required this.avgUnits,
    required this.loadLabel,
    required this.onSelect,
  });

  final SizingResult sizing;
  final double selected;
  final bool custom;
  final _Fmt kwLabel;
  final String avgUnits;
  final String loadLabel;
  final void Function(double kw, {bool custom}) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recommendedLabel, style: theme.textTheme.labelLarge),
            Text(
              kwLabel(sizing.recommendedKw),
              key: const Key('sizing.recommended'),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            Text(l10n.requiredKwNote(avgUnits)),
            if (sizing.exceedsSanctionedLoad || sizing.limitedByRoof) ...[
              const SizedBox(height: 8),
              if (sizing.exceedsSanctionedLoad)
                _Notice(
                  icon: Icons.warning_amber,
                  text: l10n.exceedsLoad(loadLabel),
                ),
              if (sizing.limitedByRoof)
                _Notice(
                  icon: Icons.roofing,
                  text: l10n.limitedByRoof(kwLabel(sizing.maxKwByRoof ?? 0)),
                ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kw in sizing.options)
                  ChoiceChip(
                    key: Key('sizing.option.$kw'),
                    label: Text(kwLabel(kw)),
                    selected: !custom && selected == kw,
                    onSelected: (_) => onSelect(kw),
                  ),
                ChoiceChip(
                  label: Text(l10n.customSize),
                  selected: custom,
                  onSelected: (_) => onSelect(selected, custom: true),
                ),
              ],
            ),
            if (custom)
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: clampKw(selected),
                      min: 0.5,
                      max: 10,
                      divisions: 19,
                      label: kwLabel(selected),
                      onChanged: (v) => onSelect(v, custom: true),
                    ),
                  ),
                  Text(kwLabel(selected), style: theme.textTheme.titleMedium),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  const _CompareTable({
    required this.calc,
    required this.options,
    required this.lang,
  });

  final SizingCalculator calc;
  final List<double> options;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final evaluated = [for (final kw in options) calc.evaluate(kw)];
    String rupees(num v) => IndianFormat.rupees(v, languageCode: lang);
    final rows = <(String, String Function(SizingOption))>[
      (
        l10n.rowGeneration,
        (o) => IndianFormat.number(o.monthlyKwh.round(), languageCode: lang),
      ),
      (l10n.rowSubsidy, (o) => rupees(o.subsidy.total)),
      (l10n.rowNet, (o) => rupees(o.netPrice)),
      (l10n.rowEmi, (o) => rupees(o.loan.emi.round())),
      (
        l10n.rowPayback,
        (o) => o.savings?.paybackYears == null
            ? '—'
            : l10n.paybackYears(o.savings!.paybackYears!.toStringAsFixed(1)),
      ),
    ];
    return _Section(
      title: l10n.compareTitle,
      icon: Icons.compare_arrows,
      children: [
        Table(
          columnWidths: const {0: FlexColumnWidth(1.4)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                const SizedBox.shrink(),
                for (final o in evaluated)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      IndianFormat.kw(o.kw, languageCode: lang),
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
              ],
            ),
            for (final (label, value) in rows)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(label, style: theme.textTheme.bodyMedium),
                  ),
                  for (final o in evaluated)
                    Text(
                      value(o),
                      key: Key('compare.$label.${o.kw}'),
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _GenerationChart extends StatelessWidget {
  const _GenerationChart({required this.generation, required this.usage});

  final List<double> generation;
  final List<double> usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final maxY =
        [...generation, ...usage].fold<double>(0, (a, b) => b > a ? b : a) *
        1.15;
    return BarChart(
      BarChartData(
        maxY: maxY <= 0 ? 1 : maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: const BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  DateFormat.MMM(locale)
                      .format(DateTime(2026, v.toInt() + 1))
                      .characters
                      .first,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ),
        extraLinesData: usage.isEmpty
            ? null
            : ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: usage.fold<double>(0, (a, b) => a + b) / usage.length,
                    color: theme.colorScheme.onSurfaceVariant,
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                  ),
                ],
              ),
        barGroups: [
          for (var i = 0; i < 12; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: generation[i],
                  width: 14,
                  color: const Color(0xFFE07B00),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SubsidyCard extends StatelessWidget {
  const _SubsidyCard({
    required this.option,
    required this.rupees,
    required this.kw,
  });

  final SizingOption option;
  final _Fmt rupees;
  final _Fmt kw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = option.subsidy;
    List<Widget> lines(RuleAmount r) => [
      for (final line in r.lines)
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            l10n.subsidyLine(
              _trim(line.fromKw),
              _trim(line.toKw),
              rupees(line.perKw),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
    ];
    return _Section(
      title: l10n.subsidySection,
      icon: Icons.volunteer_activism_outlined,
      children: [
        if (!s.eligible)
          _Notice(
            icon: Icons.block,
            text: l10n.noSubsidyNonDcr,
            color: Theme.of(context).colorScheme.error,
          )
        else ...[
          _Line(l10n.centralSubsidy, rupees(s.central.amount)),
          ...lines(s.central),
          if (s.state.amount > 0) ...[
            _Line(l10n.stateSubsidy, rupees(s.state.amount)),
            ...lines(s.state),
          ],
        ],
        const Divider(),
        _Line(
          l10n.totalSubsidy,
          rupees(s.total),
          bold: true,
          valueKey: const Key('sizing.totalSubsidy'),
        ),
        if (s.eligible && option.kw > 0)
          Text(
            l10n.subsidyPerKw(rupees(s.perKw(option.kw).round())),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _EmiVsBill extends StatelessWidget {
  const _EmiVsBill({
    required this.emi,
    required this.bill,
    required this.rupees,
  });

  final double emi;
  final double? bill;
  final _Fmt rupees;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget tile(String label, double value, Color color, Key key) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            Text(
              rupees(value.round()),
              key: key,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(l10n.perMonth, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            tile(
              l10n.emiLabel,
              emi,
              const Color(0xFF2E7D32),
              const Key('sizing.emi'),
            ),
            if (bill != null) ...[
              const SizedBox(width: 12),
              tile(
                l10n.currentBillLabel,
                bill!,
                theme.colorScheme.error,
                const Key('sizing.bill'),
              ),
            ],
          ],
        ),
        if (bill != null && emi < bill!) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.thumb_up_alt_outlined,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.emiVsBillGood)),
            ],
          ),
        ],
      ],
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({
    required this.calc,
    required this.option,
    required this.rupees,
  });

  final SizingCalculator calc;
  final SizingOption option;
  final _Fmt rupees;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = option.savings;
    final years = '${calc.solar.lifetimeYears}';
    return _Section(
      title: l10n.savingsSection,
      icon: Icons.savings_outlined,
      children: [
        if (calc.tariffSource == TariffSource.fromBill)
          _Notice(icon: Icons.info_outline, text: l10n.noTariffUsingBill),
        if (s == null)
          _Notice(icon: Icons.info_outline, text: l10n.noTariff)
        else ...[
          _Line(l10n.monthlySaving, rupees(s.monthlySavingYear1.round())),
          _Line(
            l10n.paybackLabel,
            s.paybackYears == null
                ? l10n.noPayback(years)
                : l10n.paybackYears(s.paybackYears!.toStringAsFixed(1)),
            valueKey: const Key('sizing.payback'),
          ),
          _Line(
            l10n.lifetimeSavings(years),
            rupees(s.lifetimeSaving.round()),
            bold: true,
          ),
        ],
      ],
    );
  }
}
