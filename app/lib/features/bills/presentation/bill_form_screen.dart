import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../leads/application/leads_providers.dart';
import '../data/bills_repository.dart';
import '../domain/bill.dart';

/// Check and confirm a bill: prefilled from an AI scan (low-confidence
/// fields highlighted) or typed by hand. Nothing is saved until "Confirm".
class BillFormScreen extends ConsumerStatefulWidget {
  const BillFormScreen({
    super.key,
    required this.leadId,
    this.billId,
    this.scanId,
  });

  final String leadId;
  final String? billId;
  final String? scanId;

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _c = <String, TextEditingController>{
    for (final k in [
      'discom',
      'consumer',
      'name',
      'tariff',
      'load',
      'period',
      'avg',
      'amount',
    ])
      k: TextEditingController(),
  };
  final _months = <String, TextEditingController>{};
  BillInput _input = const BillInput();
  bool _loaded = false;
  bool _saving = false;
  int _duplicates = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(billsRepositoryProvider);
    var input = const BillInput();
    if (widget.billId != null) {
      final bill = await repo.getBill(widget.billId!);
      if (bill != null) input = BillInput.fromBill(bill);
    } else if (widget.scanId != null) {
      final job = await repo.getScan(widget.scanId!);
      if (job?.result != null) {
        input = BillInput.fromScan(job!.result!, photoId: job.photoId);
      } else if (job != null) {
        input = BillInput(photoId: job.photoId);
      }
    }
    String n(double? v) => v == null
        ? ''
        : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());
    _input = input;
    _c['discom']!.text = input.discom;
    _c['consumer']!.text = input.consumerNumber;
    _c['name']!.text = input.customerName;
    _c['tariff']!.text = input.tariffCategory;
    _c['load']!.text = n(input.sanctionedLoadKw);
    _c['period']!.text = input.billingPeriod;
    _c['avg']!.text = n(input.avgMonthlyUnits);
    _c['amount']!.text = n(input.billAmount);
    final keys = input.unitsMonthly.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    for (final k in keys) {
      _months[k] = TextEditingController(text: n(input.unitsMonthly[k]));
    }
    await _checkDuplicate();
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    for (final c in [..._c.values, ..._months.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _checkDuplicate() async {
    final n = await ref
        .read(billsRepositoryProvider)
        .countDuplicateConsumers(
          consumerNumber: _c['consumer']!.text,
          leadId: widget.leadId,
        );
    if (mounted && n != _duplicates) setState(() => _duplicates = n);
  }

  double? _parse(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.replaceAll(',', '').trim());

  void _recalcAverage() {
    final values = {
      for (final e in _months.entries)
        if (_parse(e.value.text) != null) e.key: _parse(e.value.text)!,
    };
    final avg = averageUnits(values);
    if (avg != null) _c['avg']!.text = avg.toInt().toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    final input = _input.copyWith(
      discom: _c['discom']!.text,
      consumerNumber: _c['consumer']!.text.replaceAll(RegExp(r'\s'), ''),
      customerName: _c['name']!.text,
      tariffCategory: _c['tariff']!.text,
      sanctionedLoadKw: _parse(_c['load']!.text),
      billingPeriod: _c['period']!.text,
      avgMonthlyUnits: _parse(_c['avg']!.text),
      billAmount: _parse(_c['amount']!.text),
      unitsMonthly: {
        for (final e in _months.entries)
          if (_parse(e.value.text) != null) e.key: _parse(e.value.text)!,
      },
    );
    try {
      final repo = ref.read(billsRepositoryProvider);
      await repo.saveBill(
        id: widget.billId,
        leadId: widget.leadId,
        companyId: member.company.id,
        userId: member.profile.id,
        input: input,
      );
      if (widget.scanId != null) await repo.removeScan(widget.scanId!);
      messenger.showSnackBar(SnackBar(content: Text(l10n.billSaved)));
      router.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    await ref.read(billsRepositoryProvider).deleteBill(widget.billId!);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final warn = theme.colorScheme.tertiary;

    /// Fields the AI marked medium/low get an amber outline and a hint.
    InputDecoration deco(String label, String field, {String? suffix}) {
      final c = _input.confidence[field];
      final unsure = c == FieldConfidence.low || c == FieldConfidence.medium;
      return InputDecoration(
        labelText: label,
        suffixText: suffix,
        helperText: unsure ? l10n.checkThisField : null,
        helperStyle: TextStyle(color: warn),
        prefixIcon: unsure ? Icon(Icons.help_outline, color: warn) : null,
        enabledBorder: unsure
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: warn, width: 2),
              )
            : null,
      );
    }

    String? number(String? v, {bool required = false}) {
      if ((v ?? '').trim().isEmpty) return required ? l10n.requiredField : null;
      final n = _parse(v!);
      return n == null || n < 0 ? l10n.invalidNumber : null;
    }

    final numeric = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.billFormTitle),
        actions: [
          if (widget.billId != null)
            IconButton(
              tooltip: l10n.deleteBill,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            key: const Key('billForm.save'),
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
            label: Text(l10n.confirmBill),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_duplicates > 0) ...[
                  Card(
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.errorContainer,
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      title: Text(
                        l10n.duplicateConsumer,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  key: const Key('billForm.avg'),
                  controller: _c['avg'],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: numeric,
                  style: theme.textTheme.titleLarge,
                  decoration: deco(l10n.avgUnitsLabel, 'units_this_bill'),
                  validator: (v) => number(v, required: true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('billForm.load'),
                        controller: _c['load'],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: numeric,
                        decoration: deco(
                          l10n.sanctionedLoadLabel,
                          'sanctioned_load_kw',
                        ),
                        validator: number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: const Key('billForm.amount'),
                        controller: _c['amount'],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: numeric,
                        decoration: deco(l10n.billAmountLabel, 'bill_amount'),
                        validator: number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _c['discom'],
                  textCapitalization: TextCapitalization.characters,
                  decoration: deco(l10n.discomLabel, 'discom'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('billForm.consumer'),
                  controller: _c['consumer'],
                  decoration: deco(l10n.consumerNumberLabel, 'consumer_number'),
                  onChanged: (_) => _checkDuplicate(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _c['name'],
                  textCapitalization: TextCapitalization.words,
                  decoration: deco(l10n.billCustomerNameLabel, 'customer_name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _c['tariff'],
                        decoration: deco(
                          l10n.tariffCategoryLabel,
                          'tariff_category',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _c['period'],
                        decoration: deco(
                          l10n.billingPeriodLabel,
                          'billing_period',
                        ),
                      ),
                    ),
                  ],
                ),
                if (_months.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.unitsHistoryTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in _months.entries)
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: e.value,
                            keyboardType: TextInputType.number,
                            inputFormatters: numeric,
                            decoration: InputDecoration(labelText: e.key),
                            onChanged: (_) => _recalcAverage(),
                            validator: number,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
