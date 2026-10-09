import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/user_role.dart';
import '../../leads/application/leads_providers.dart';
import '../../proposals/data/proposals_repository.dart';
import '../../proposals/domain/proposal.dart';

String productTypeLabel(AppLocalizations l10n, ProductType t) => switch (t) {
  ProductType.panel => l10n.typePanel,
  ProductType.inverter => l10n.typeInverter,
  ProductType.structure => l10n.typeStructure,
  ProductType.other => l10n.typeOther,
};

/// Owner: panel, inverter and structure catalogue with prices and
/// DCR / ALMM / approved-list flags.
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final products = ref.watch(productsProvider()).value ?? const <Product>[];
    final isOwner =
        ref.watch(currentMemberProvider)?.profile.role == UserRole.owner;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProducts)),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              key: const Key('products.add'),
              onPressed: () => _edit(context, ref, null),
              icon: const Icon(Icons.add),
              label: Text(l10n.addProduct),
            )
          : null,
      body: products.isEmpty
          ? EmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.noProducts,
              body: l10n.noProductsBody,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                for (final type in ProductType.values)
                  if (products.any((p) => p.type == type)) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      child: Text(
                        productTypeLabel(l10n, type),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    for (final p in products.where((p) => p.type == type))
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          enabled: p.active,
                          title: Text(p.label),
                          subtitle: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (p.wattPeak != null)
                                Text('${p.wattPeak!.round()} Wp'),
                              if (p.warrantyYears != null)
                                Text('· ${p.warrantyYears}y'),
                              if (p.isDcr) const _Tag('DCR', Colors.green),
                              if (p.almmListed)
                                const _Tag('ALMM', Colors.green),
                              if (p.type == ProductType.panel &&
                                  !p.subsidyEligible)
                                _Tag(
                                  l10n.tagNoSubsidy,
                                  theme.colorScheme.error,
                                ),
                              if (p.approvedList)
                                _Tag(l10n.tagApproved, Colors.green),
                            ],
                          ),
                          trailing: Text(
                            IndianFormat.rupees(
                              p.unitPrice,
                              languageCode: lang,
                            ),
                            style: theme.textTheme.titleSmall,
                          ),
                          onTap: isOwner ? () => _edit(context, ref, p) : null,
                        ),
                      ),
                  ],
              ],
            ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Product? p) async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ProductForm(product: p, companyId: member.company.id),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: TextStyle(fontSize: 11, color: color)),
  );
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm({required this.product, required this.companyId});

  final Product? product;
  final String companyId;

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late ProductType _type = widget.product?.type ?? ProductType.panel;
  late final _brand = TextEditingController(text: widget.product?.brand);
  late final _model = TextEditingController(text: widget.product?.model);
  late final _wp = TextEditingController(
    text: widget.product?.wattPeak?.round().toString(),
  );
  late final _length = TextEditingController(
    text: widget.product?.lengthM?.toString(),
  );
  late final _width = TextEditingController(
    text: widget.product?.widthM?.toString(),
  );
  late final _warranty = TextEditingController(
    text: widget.product?.warrantyYears?.toString(),
  );
  late final _price = TextEditingController(
    text: widget.product?.unitPrice.round().toString(),
  );
  late bool _dcr = widget.product?.isDcr ?? false;
  late bool _almm = widget.product?.almmListed ?? false;
  late bool _approved = widget.product?.approvedList ?? false;
  late bool _active = widget.product?.active ?? true;

  @override
  void dispose() {
    for (final c in [_brand, _model, _wp, _length, _width, _warranty, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    await ref
        .read(proposalsRepositoryProvider)
        .saveProduct(
          Product(
            id: widget.product?.id ?? const Uuid().v4(),
            companyId: widget.companyId,
            type: _type,
            brand: _brand.text,
            model: _model.text,
            wattPeak: double.tryParse(_wp.text),
            lengthM: _type == ProductType.panel
                ? double.tryParse(_length.text)
                : null,
            widthM: _type == ProductType.panel
                ? double.tryParse(_width.text)
                : null,
            isDcr: _dcr,
            almmListed: _almm,
            approvedList: _approved,
            warrantyYears: int.tryParse(_warranty.text),
            unitPrice: double.tryParse(_price.text) ?? 0,
            active: _active,
          ),
          companyId: widget.companyId,
        );
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.productSaved)));
  }

  Widget _metres(TextEditingController c, String label) => TextFormField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    decoration: InputDecoration(labelText: label),
    validator: (v) {
      if ((v ?? '').isEmpty) return null;
      final m = double.tryParse(v!);
      return m != null && m > 0.3 && m < 3.5
          ? null
          : context.l10n.requiredField;
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? required(String? v) =>
        (v ?? '').trim().isEmpty ? l10n.requiredField : null;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.product == null ? l10n.addProduct : l10n.editProduct,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<ProductType>(
              segments: [
                for (final t in ProductType.values)
                  ButtonSegment(
                    value: t,
                    label: Text(productTypeLabel(l10n, t)),
                  ),
              ],
              selected: {_type},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              decoration: InputDecoration(labelText: l10n.brandLabel),
              validator: required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _model,
              decoration: InputDecoration(labelText: l10n.modelLabel),
              validator: required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_type == ProductType.panel) ...[
                  Expanded(
                    child: TextFormField(
                      controller: _wp,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      decoration: InputDecoration(
                        labelText: l10n.wattPeakLabel,
                      ),
                      validator: required,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TextFormField(
                    controller: _warranty,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: InputDecoration(labelText: l10n.warrantyLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: InputDecoration(labelText: l10n.unitPriceLabel),
              validator: required,
            ),
            if (_type == ProductType.panel) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _metres(_length, l10n.panelLengthLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: _metres(_width, l10n.panelWidthLabel)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.panelSizeHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.dcrLabel),
                value: _dcr,
                onChanged: (v) => setState(() => _dcr = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.almmLabel),
                value: _almm,
                onChanged: (v) => setState(() => _almm = v),
              ),
            ],
            if (_type == ProductType.inverter)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.approvedListLabel),
                value: _approved,
                onChanged: (v) => setState(() => _approved = v),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.activeLabel),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
