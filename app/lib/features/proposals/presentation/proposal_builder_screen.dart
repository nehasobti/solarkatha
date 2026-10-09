import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_core/solar_core.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/user_role.dart';
import '../../bills/application/bills_providers.dart';
import '../../bills/data/bills_repository.dart';
import '../../bills/domain/bill.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/domain/lead.dart';
import '../../sizing/data/sizing_repository.dart';
import '../../sizing/domain/sizing_calculator.dart';
import '../../sizing/domain/sizing_config.dart';
import '../../survey/data/survey_repository.dart';
import '../../survey/domain/site.dart';
import '../data/proposals_repository.dart';
import '../domain/proposal.dart';
import 'proposal_actions.dart';

/// Pick panel and inverter, price, loan and language; compliance checklist;
/// then PDF, WhatsApp, signature and UPI payment link.
class ProposalBuilderScreen extends ConsumerWidget {
  const ProposalBuilderScreen({
    super.key,
    required this.leadId,
    this.proposalId,
    this.initialKw,
  });

  final String leadId;
  final String? proposalId;
  final double? initialKw;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lead = ref.watch(leadProvider(leadId)).value;
    final bills = ref.watch(leadBillsProvider(leadId));
    final config = ref.watch(sizingConfigProvider);
    final products = ref.watch(productsProvider(activeOnly: true));
    final site = ref.watch(leadSiteProvider(leadId));
    final proposal = proposalId == null
        ? null
        : ref.watch(proposalProvider(proposalId!));

    Widget body;
    if (lead == null ||
        !bills.hasValue ||
        config.isLoading ||
        !products.hasValue ||
        !site.hasValue ||
        (proposal != null && !proposal.hasValue)) {
      body = const Center(child: CircularProgressIndicator());
    } else if (config.value == null) {
      body = EmptyState(
        icon: Icons.cloud_sync_outlined,
        title: l10n.configMissing,
      );
    } else {
      body = _Builder(
        key: ValueKey(proposal?.value?.id ?? 'new'),
        lead: lead,
        bill: bills.value!.firstOrNull,
        config: config.value!,
        products: products.value!,
        site: site.value,
        existing: proposal?.value,
        initialKw: initialKw,
      );
    }
    final title = proposal?.value == null
        ? l10n.newProposal
        : l10n.proposalVersion('${proposal!.value!.version}');
    return Scaffold(
      appBar: AppBar(
        title: Text(lead == null ? title : '$title · ${lead.name}'),
      ),
      body: body,
    );
  }
}

class _Builder extends ConsumerStatefulWidget {
  const _Builder({
    super.key,
    required this.lead,
    required this.bill,
    required this.config,
    required this.products,
    required this.site,
    required this.existing,
    required this.initialKw,
  });

  final Lead lead;
  final Bill? bill;
  final SizingConfig config;
  final List<Product> products;

  /// Roof survey: roof type (compliance) and the roof's kW limit.
  final Site? site;
  final Proposal? existing;
  final double? initialKw;

  @override
  ConsumerState<_Builder> createState() => _BuilderState();
}

class _BuilderState extends ConsumerState<_Builder> {
  late final _kw = TextEditingController();
  late final _gross = TextEditingController();
  late final _rate = TextEditingController();
  String? _panelId;
  String? _inverterId;
  String _language = 'en';
  int _years = 10;
  String? _bank;
  ComplianceState _compliance = const ComplianceState();
  int _photos = 0;
  int _duplicates = 0;
  List<double>? _perKw;
  bool _saving = false;

  List<Product> _of(ProductType t) =>
      widget.products.where((p) => p.type == t).toList();

  Product? get _panel =>
      widget.products.where((p) => p.id == _panelId).firstOrNull;
  Product? get _inverter =>
      widget.products.where((p) => p.id == _inverterId).firstOrNull;

  static String _n(double? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2));

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final loan = widget.config.loans.firstOrNull;
    if (e != null) {
      _kw.text = _n(e.systemKw);
      _panelId = e.panelProductId;
      _inverterId = e.inverterProductId;
      _gross.text = e.grossPrice.round().toString();
      _language = e.language;
      _rate.text = _n(e.loan?.rate ?? loan?.ratePct);
      _years = e.loan?.years ?? loan?.maxYears ?? 10;
      _bank = e.loan?.bank ?? loan?.bankName;
      _compliance = e.compliance;
    } else {
      _kw.text = _n(widget.initialKw ?? 3);
      _panelId =
          (_of(ProductType.panel).where((p) => p.subsidyEligible).firstOrNull ??
                  _of(ProductType.panel).firstOrNull)
              ?.id;
      _inverterId = _of(ProductType.inverter).firstOrNull?.id;
      _rate.text = _n(loan?.ratePct);
      _years = loan?.maxYears ?? 10;
      _bank = loan?.bankName;
      _language = ref.read(appPreferencesControllerProvider).languageCode;
    }
    _loadFacts();
  }

  Future<void> _loadFacts() async {
    final repo = ref.read(proposalsRepositoryProvider);
    final photos = await repo.photoCount(widget.lead.id);
    final dups = await ref
        .read(billsRepositoryProvider)
        .countDuplicateConsumers(
          consumerNumber: widget.bill?.consumerNumber ?? '',
          leadId: widget.lead.id,
        );
    final gen = await ref
        .read(generationServiceProvider)
        .estimate(
          lat: widget.lead.lat,
          lng: widget.lead.lng,
          config: widget.config.solar,
        );
    if (mounted) {
      setState(() {
        _photos = photos;
        _duplicates = dups;
        _perKw = gen.monthlyPerKw;
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_kw, _gross, _rate]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Installed kW: whole panels when a panel is chosen.
  double get _systemKw {
    final asked = double.tryParse(_kw.text) ?? 0;
    final wp = _panel?.wattPeak;
    if (wp == null || wp <= 0 || asked <= 0) return asked;
    return installedKw(panelCount(asked, wp), wp);
  }

  int? get _panelCount {
    final wp = _panel?.wattPeak;
    final asked = double.tryParse(_kw.text) ?? 0;
    return wp == null || wp <= 0 || asked <= 0 ? null : panelCount(asked, wp);
  }

  ProposalDraft _draft() {
    final kw = _systemKw;
    final solar = widget.config.solar;
    // Empty price field = automatic (kW × default price per kW).
    final gross = double.tryParse(_gross.text) ?? kw * solar.pricePerKw;
    final calc = SizingCalculator(
      widget.config,
      SizingInputs(
        avgMonthlyUnits: widget.bill?.avgMonthlyUnits ?? 0,
        monthlyPerKw:
            _perKw ?? fallbackMonthlyPerKw(solar.defaultYieldKwhPerKwDay),
        history12: widget.bill?.history12,
        stateCode: widget.lead.stateCode,
        discom: widget.bill?.discom,
        billAmount: widget.bill?.billAmount,
        panelsEligible: _panel?.subsidyEligible ?? false,
        pricePerKw: kw > 0 ? gross / kw : solar.pricePerKw,
        loanRatePct: double.tryParse(_rate.text),
        loanYears: _years,
      ),
    );
    final option = calc.evaluate(kw <= 0 ? 0.0001 : kw);
    final hasUsage = (widget.bill?.avgMonthlyUnits ?? 0) > 0;
    return ProposalDraft(
      systemKw: kw,
      language: _language,
      panel: _panel,
      panelCount: _panelCount,
      inverter: _inverter,
      grossPrice: gross,
      subsidy: option.subsidy,
      loan: LoanTerms(
        amount: option.netPrice,
        rate: option.loan.annualRatePct,
        years: _years,
        emi: option.loan.emi.roundToDouble(),
        bank: _bank,
      ),
      monthlyGeneration: option.generation,
      savings: hasUsage ? option.savings : null,
      currentMonthlyBill: calc.currentMonthlyBill,
      compliance: _compliance,
    );
  }

  ComplianceResult _complianceResult(ProposalDraft d) => evaluateCompliance(
    ComplianceInput(
      panelsDcr: d.panel?.isDcr ?? false,
      panelsAlmm: d.panel?.almmListed ?? false,
      inverterApproved: d.inverter?.approvedList ?? false,
      ownConnectionConfirmed: _compliance.ownConnection,
      consumerNumber: widget.bill?.consumerNumber,
      photoCount: _photos,
      roofTypeRecorded: widget.site?.roofType != null,
      duplicateConsumerLeads: _duplicates,
    ),
    ownerOverride: _compliance.overrideBy != null,
  );

  Future<void> _save() async {
    final member = ref.read(currentMemberProvider);
    if (member == null || _systemKw <= 0) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      final repo = ref.read(proposalsRepositoryProvider);
      final draft = _draft();
      if (widget.existing == null) {
        final id = await repo.createProposal(
          leadId: widget.lead.id,
          companyId: member.company.id,
          userId: member.profile.id,
          draft: draft,
        );
        messenger.showSnackBar(SnackBar(content: Text(l10n.proposalSaved)));
        unawaited(router.pushReplacement(Routes.proposal(widget.lead.id, id)));
      } else {
        await repo.updateProposal(widget.existing!.id, draft);
        messenger.showSnackBar(SnackBar(content: Text(l10n.proposalSaved)));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _newVersion() async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    final router = GoRouter.of(context);
    final id = await ref
        .read(proposalsRepositoryProvider)
        .createProposal(
          leadId: widget.lead.id,
          companyId: member.company.id,
          userId: member.profile.id,
          draft: _draft(),
        );
    unawaited(router.pushReplacement(Routes.proposal(widget.lead.id, id)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final member = ref.watch(currentMemberProvider);
    final isOwner = member?.profile.role == UserRole.owner;
    final existing = widget.existing;
    final editable = existing?.isEditable ?? true;
    final d = _draft();
    final compliance = _complianceResult(d);
    String rupees(num v) => IndianFormat.rupees(v, languageCode: lang);
    void changed() => setState(() {});

    final panels = _of(ProductType.panel);
    final inverters = _of(ProductType.inverter);

    Widget section(String title, IconData icon, List<Widget> children) => Card(
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

    Widget line(String label, String value, {bool bold = false, Key? key}) {
      final style = bold
          ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
          : theme.textTheme.bodyLarge;
      return Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, key: key, style: style),
        ],
      );
    }

    final checkLabels = <ComplianceCheck, String>{
      ComplianceCheck.panelsDcr: l10n.checkPanelsDcr,
      ComplianceCheck.panelsAlmm: l10n.checkPanelsAlmm,
      ComplianceCheck.inverterApproved: l10n.checkInverterApproved,
      ComplianceCheck.ownConnection: l10n.checkOwnConnection,
      ComplianceCheck.consumerNumber: l10n.checkConsumerNumber,
      ComplianceCheck.roofPhotos: l10n.checkRoofPhotos('$_photos'),
      ComplianceCheck.roofType: l10n.checkRoofType,
      ComplianceCheck.singleSubsidy: l10n.checkSingleSubsidy,
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!editable)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.proposalLocked),
                  trailing: FilledButton.tonal(
                    key: const Key('proposal.newVersion'),
                    onPressed: _newVersion,
                    child: Text(l10n.newVersion),
                  ),
                ),
              ),
            section(l10n.systemSection, Icons.solar_power_outlined, [
              TextField(
                key: const Key('proposal.kw'),
                controller: _kw,
                enabled: editable,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(labelText: l10n.systemKwLabel),
                onChanged: (_) => changed(),
              ),
              DropdownButtonFormField<String>(
                key: const Key('proposal.panel'),
                initialValue: panels.any((p) => p.id == _panelId)
                    ? _panelId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.panelLabel),
                hint: Text(l10n.selectProduct),
                items: [
                  for (final p in panels)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        '${p.label}${p.subsidyEligible ? ' · DCR' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: editable
                    ? (v) => setState(() => _panelId = v)
                    : null,
              ),
              if (_panelCount != null && _panel?.wattPeak != null)
                Text(
                  l10n.panelsNeeded(
                    '$_panelCount',
                    '${_panel!.wattPeak!.round()}',
                    IndianFormat.kw(_systemKw, languageCode: lang),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              if (widget.site?.maxKw != null &&
                  _systemKw > widget.site!.maxKw! + 1e-9)
                Text(
                  l10n.roofLimitWarning(
                    IndianFormat.kw(widget.site!.maxKw!, languageCode: lang),
                  ),
                  key: const Key('proposal.roofLimit'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              DropdownButtonFormField<String>(
                initialValue: inverters.any((p) => p.id == _inverterId)
                    ? _inverterId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.inverterLabel),
                hint: Text(l10n.selectProduct),
                items: [
                  for (final p in inverters)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text(p.label, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: editable
                    ? (v) => setState(() => _inverterId = v)
                    : null,
              ),
            ]),
            section(l10n.priceSection, Icons.currency_rupee, [
              TextField(
                key: const Key('proposal.gross'),
                controller: _gross,
                enabled: editable,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.grossPriceLabel,
                  prefixText: '₹ ',
                  hintText: d.grossPrice.round().toString(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (_) => changed(),
              ),
              line(
                l10n.centralSubsidy,
                '− ${rupees(d.subsidy.central.amount)}',
              ),
              if (d.subsidy.state.amount > 0)
                line(l10n.stateSubsidy, '− ${rupees(d.subsidy.state.amount)}'),
              if (!d.subsidy.eligible)
                Text(
                  l10n.noSubsidyNonDcr,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              line(
                l10n.netPrice,
                rupees(d.netPrice),
                bold: true,
                key: const Key('proposal.net'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rate,
                      enabled: editable,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.interestRate),
                      onChanged: (_) => changed(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _years,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.tenureYears),
                      items: [
                        for (var y = 1; y <= 15; y++)
                          DropdownMenuItem(value: y, child: Text('$y')),
                      ],
                      onChanged: editable
                          ? (v) => setState(() => _years = v!)
                          : null,
                    ),
                  ),
                ],
              ),
              line(
                l10n.emiLabel,
                rupees(d.loan.emi),
                key: const Key('proposal.emi'),
              ),
              Row(
                children: [
                  Expanded(child: Text(l10n.languageForProposal)),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'hi',
                        label: Text(l10n.languageHindi),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text(l10n.languageEnglish),
                      ),
                    ],
                    selected: {_language},
                    showSelectedIcon: false,
                    onSelectionChanged: editable
                        ? (s) => setState(() => _language = s.first)
                        : null,
                  ),
                ],
              ),
            ]),
            section(l10n.complianceTitle, Icons.fact_check_outlined, [
              for (final item in compliance.items)
                item.manual
                    ? CheckboxListTile(
                        key: Key('compliance.${item.check.name}'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: item.passed,
                        title: Text(checkLabels[item.check]!),
                        onChanged: editable
                            ? (v) => setState(() {
                                _compliance =
                                    item.check == ComplianceCheck.ownConnection
                                    ? _compliance.copyWith(ownConnection: v)
                                    : _compliance.copyWith(roofType: v);
                              })
                            : null,
                      )
                    : ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.passed ? Icons.check_circle : Icons.cancel,
                          color: item.passed
                              ? const Color(0xFF2E7D32)
                              : theme.colorScheme.error,
                        ),
                        title: Text(checkLabels[item.check]!),
                      ),
              if (isOwner && !compliance.allPassed)
                SwitchListTile(
                  key: const Key('compliance.override'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.ownerOverride),
                  value: _compliance.overrideBy != null,
                  onChanged: editable
                      ? (v) => setState(() {
                          _compliance = _compliance.copyWith(
                            overrideBy: () => v ? member!.profile.id : null,
                          );
                        })
                      : null,
                ),
            ]),
            if (editable)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FilledButton.icon(
                  key: const Key('proposal.save'),
                  onPressed: _saving || _systemKw <= 0 ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.saveDraft),
                ),
              ),
            if (existing != null)
              ProposalActions(
                proposal: existing,
                lead: widget.lead,
                companyName: member?.company.name ?? '',
                canSend: compliance.canSend,
              ),
          ],
        ),
      ),
    );
  }
}
