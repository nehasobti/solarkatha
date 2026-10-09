import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../leads/application/leads_providers.dart';
import '../data/admin_repository.dart';

/// Business numbers live in config tables. Owners override a default for
/// their company; removing the override brings the default back.
class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabs = [
      l10n.appSettingsTitle,
      l10n.loanPresetsTitle,
      l10n.subsidyRulesTitle,
      l10n.tariffsTitle,
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navConfig),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final t in tabs) Tab(text: t)],
          ),
        ),
        body: const TabBarView(
          children: [_AppSettings(), _Loans(), _SubsidyRules(), _Tariffs()],
        ),
      ),
    );
  }
}

String _show(Object? json) {
  try {
    final v = jsonDecode(json as String? ?? 'null');
    return v is String ? v : jsonEncode(v);
  } catch (_) {
    return '$json';
  }
}

Future<String?> _editText(
  BuildContext context,
  String title,
  String initial, {
  bool multiline = false,
}) async {
  final l10n = context.l10n;
  final c = TextEditingController(text: initial);
  final v = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 480,
        child: TextField(
          key: const Key('config.edit'),
          controller: c,
          autofocus: true,
          minLines: 1,
          maxLines: multiline ? 8 : 4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('config.save'),
          onPressed: () => Navigator.pop(context, c.text),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  c.dispose();
  return v;
}

Widget _note(BuildContext context) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  child: Text(
    context.l10n.configCompanyNote,
    style: Theme.of(context).textTheme.bodySmall,
  ),
);

Widget _ownChip(BuildContext context) => Chip(
  label: Text(context.l10n.overridden),
  visualDensity: VisualDensity.compact,
  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
);

class _AppSettings extends ConsumerWidget {
  const _AppSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final companyId = ref.watch(currentMemberProvider)?.company.id ?? '';
    final rows =
        ref.watch(configRowsProvider('app_config', 'key')).value ?? const [];
    // One entry per key: the company's row wins over the default.
    final byKey = <String, ConfigRow>{};
    for (final r in rows) {
      final k = r['key']! as String;
      if (!byKey.containsKey(k) || r.own) byKey[k] = r;
    }
    final repo = ref.read(adminRepositoryProvider);
    return ListView(
      children: [
        _note(context),
        for (final MapEntry(key: key, value: row) in byKey.entries)
          ListTile(
            key: Key('config.$key'),
            title: Text(key),
            subtitle: Text(
              _show(row['value']),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: row.own
                ? IconButton(
                    tooltip: l10n.remove,
                    icon: const Icon(Icons.restart_alt),
                    onPressed: () => repo.deleteRow('app_config', row.id),
                  )
                : const Icon(Icons.edit_outlined, size: 18),
            leading: row.own ? const Icon(Icons.star, size: 18) : null,
            onTap: () async {
              final before = jsonDecode(row['value'] as String? ?? 'null');
              final text = await _editText(
                context,
                key,
                _show(row['value']),
                multiline: key.startsWith('wa_template'),
              );
              if (text == null) return;
              Object? value = text;
              if (before is! String) {
                try {
                  value = jsonDecode(text);
                } on FormatException {
                  value = text;
                }
              }
              await repo.setAppConfig(companyId, key, value);
            },
          ),
      ],
    );
  }
}

class _Loans extends ConsumerWidget {
  const _Loans();

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    String companyId, [
    ConfigRow? row,
  ]) async {
    final l10n = context.l10n;
    final bank = TextEditingController(text: row?['bank_name'] as String?);
    final rate = TextEditingController(text: '${row?['rate_pct'] ?? ''}');
    final years = TextEditingController(text: '${row?['max_years'] ?? ''}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.loanPresetsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bank,
              decoration: InputDecoration(labelText: l10n.bankNameLabel),
            ),
            TextField(
              controller: rate,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.interestRate),
            ),
            TextField(
              controller: years,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.maxYearsLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final r = double.tryParse(rate.text);
    final y = int.tryParse(years.text);
    if (ok == true && bank.text.trim().isNotEmpty && r != null && y != null) {
      await ref.read(adminRepositoryProvider).saveRow(
        'loan_presets',
        companyId,
        {
          'bank_name': bank.text.trim(),
          'rate_pct': r,
          'max_years': y,
          'sort': 0,
        },
        id: row?.own == true ? row!.id : null,
      );
    }
    bank.dispose();
    rate.dispose();
    years.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final companyId = ref.watch(currentMemberProvider)?.company.id ?? '';
    final rows =
        ref
            .watch(configRowsProvider('loan_presets', 'sort, bank_name'))
            .value ??
        const [];
    return ListView(
      children: [
        _note(context),
        for (final r in rows)
          ListTile(
            title: Text(r['bank_name'] as String? ?? ''),
            subtitle: Text(
              '${r['rate_pct']}% · ${r['max_years']} ${l10n.maxYearsLabel.toLowerCase()}',
            ),
            trailing: r.own
                ? IconButton(
                    tooltip: l10n.remove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref
                        .read(adminRepositoryProvider)
                        .deleteRow('loan_presets', r.id),
                  )
                : null,
            leading: r.own ? const Icon(Icons.star, size: 18) : null,
            onTap: () => _edit(context, ref, companyId, r),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            key: const Key('config.addLoan'),
            onPressed: () => _edit(context, ref, companyId),
            icon: const Icon(Icons.add),
            label: Text(l10n.addItem),
          ),
        ),
      ],
    );
  }
}

/// Subsidy rules and tariffs: editing a default creates the company's copy.
class _SlabRows extends ConsumerWidget {
  const _SlabRows({
    required this.table,
    required this.orderBy,
    required this.title,
    required this.amountKey,
    required this.amountLabel,
  });

  final String table;
  final String orderBy;
  final String Function(ConfigRow) title;
  final String amountKey;
  final String amountLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final companyId = ref.watch(currentMemberProvider)?.company.id ?? '';
    final rows =
        ref.watch(configRowsProvider(table, orderBy)).value ?? const [];
    final repo = ref.read(adminRepositoryProvider);
    return ListView(
      children: [
        _note(context),
        for (final r in rows)
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title(r),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (r.own) _ownChip(context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${l10n.slabsLabel}: ${_show(r['slabs'])}'),
                  if (r[amountKey] != null)
                    Text('$amountLabel: ${r[amountKey]}'),
                  if (r['valid_from'] != null)
                    Text('${l10n.validFromLabel}: ${r['valid_from']}'),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(l10n.slabsLabel),
                        onPressed: () async {
                          final text = await _editText(
                            context,
                            l10n.slabsLabel,
                            _show(r['slabs']),
                            multiline: true,
                          );
                          if (text == null) return;
                          try {
                            final slabs = jsonDecode(text);
                            if (slabs is! List) throw const FormatException();
                            await _write(repo, companyId, r, {
                              'slabs': jsonEncode(slabs),
                            });
                          } on FormatException {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.invalidJson)),
                              );
                            }
                          }
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(amountLabel),
                        onPressed: () async {
                          final text = await _editText(
                            context,
                            amountLabel,
                            '${r[amountKey] ?? ''}',
                          );
                          final amount = double.tryParse(text?.trim() ?? '');
                          if (amount == null) return;
                          await _write(repo, companyId, r, {amountKey: amount});
                        },
                      ),
                      if (r.own)
                        TextButton(
                          onPressed: () => repo.deleteRow(table, r.id),
                          child: Text(l10n.remove),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _write(
    AdminRepository repo,
    String companyId,
    ConfigRow r,
    Map<String, Object?> changes,
  ) {
    if (r.own) return repo.saveRow(table, companyId, changes, id: r.id);
    final copy = {...r.data}
      ..remove('id')
      ..remove('company_id')
      ..remove('updated_at')
      ..addAll(changes);
    return repo.saveRow(table, companyId, copy);
  }
}

class _SubsidyRules extends StatelessWidget {
  const _SubsidyRules();

  @override
  Widget build(BuildContext context) => _SlabRows(
    table: 'subsidy_rules',
    orderBy: 'scope, valid_from',
    title: (r) => '${r['scope']} · ${r['segment']}',
    amountKey: 'cap_amount',
    amountLabel: context.l10n.capLabel,
  );
}

class _Tariffs extends StatelessWidget {
  const _Tariffs();

  @override
  Widget build(BuildContext context) => _SlabRows(
    table: 'tariffs',
    orderBy: 'state_code, discom',
    title: (r) => [
      r['state_code'],
      r['discom'],
      r['category'],
    ].whereType<String>().join(' · '),
    amountKey: 'fixed_charge',
    amountLabel: context.l10n.fixedChargeLabel,
  );
}
