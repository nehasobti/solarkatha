import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../leads/application/leads_providers.dart';
import '../data/admin_repository.dart';

const brandPalette = [
  '#EA580C',
  '#F59E0B',
  '#2E7D32',
  '#00897B',
  '#1565C0',
  '#283593',
  '#6A1B9A',
  '#AD1457',
  '#C62828',
  '#37474F',
];

Color? parseHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) return null;
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}

/// Company details shown on proposals, the tracking page and WhatsApp.
class BrandingScreen extends ConsumerStatefulWidget {
  const BrandingScreen({super.key});

  @override
  ConsumerState<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends ConsumerState<BrandingScreen> {
  final _form = GlobalKey<FormState>();
  final _c = {
    for (final k in ['name', 'phone', 'address', 'gstin', 'mnre_vendor_id'])
      k: TextEditingController(),
  };
  String? _color;
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(String companyId) async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    String? v(String k) =>
        _c[k]!.text.trim().isEmpty ? null : _c[k]!.text.trim();
    await ref.read(adminRepositoryProvider).updateCompany(companyId, {
      'name': v('name') ?? '',
      'phone': v('phone'),
      'address': v('address'),
      'gstin': v('gstin')?.toUpperCase(),
      'mnre_vendor_id': v('mnre_vendor_id'),
      'brand_color': _color,
    });
    messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final companyId = ref.watch(currentMemberProvider)?.company.id;
    final company = companyId == null
        ? null
        : ref.watch(companyProvider(companyId)).value;
    if (company != null && !_loaded) {
      _loaded = true;
      for (final e in _c.entries) {
        e.value.text = (company[e.key] as String?) ?? '';
      }
      _color = company['brand_color'] as String?;
    }

    InputDecoration deco(String label) => InputDecoration(labelText: label);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navBranding)),
      body: company == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _form,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        key: const Key('brand.name'),
                        controller: _c['name'],
                        decoration: deco(l10n.companyNameLabel),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? l10n.requiredField
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _c['phone'],
                        keyboardType: TextInputType.phone,
                        decoration: deco(l10n.companyPhoneLabel),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _c['address'],
                        maxLines: 2,
                        decoration: deco(l10n.addressLabel),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _c['gstin'],
                        textCapitalization: TextCapitalization.characters,
                        decoration: deco(l10n.gstinLabel),
                        validator: (v) {
                          final s = (v ?? '').trim().toUpperCase();
                          return s.isEmpty ||
                                  RegExp(r'^[0-9]{2}[A-Z0-9]{13}$').hasMatch(s)
                              ? null
                              : l10n.gstinLabel;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _c['mnre_vendor_id'],
                        decoration: deco(l10n.mnreVendorIdLabel),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.brandColorLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final hex in brandPalette)
                            InkWell(
                              key: Key('brand.color.$hex'),
                              customBorder: const CircleBorder(),
                              onTap: () => setState(() => _color = hex),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: parseHex(hex),
                                child: _color?.toUpperCase() == hex
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        key: const Key('brand.save'),
                        onPressed: () => _save(companyId!),
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.save),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
