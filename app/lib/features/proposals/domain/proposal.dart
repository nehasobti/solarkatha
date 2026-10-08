import 'dart:convert';

import 'package:solar_core/solar_core.dart';

double _d(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s) ?? 0,
  _ => 0,
};

double? _dn(Object? v) => v == null ? null : _d(v);

Map<String, Object?> _json(Object? v) {
  if (v is Map) return v.cast<String, Object?>();
  if (v is String && v.isNotEmpty) {
    try {
      final d = jsonDecode(v);
      if (d is Map) return d.cast<String, Object?>();
    } catch (_) {}
  }
  return const {};
}

enum ProductType { panel, inverter, structure, other }

class Product {
  const Product({
    required this.id,
    required this.companyId,
    required this.type,
    required this.brand,
    required this.model,
    this.wattPeak,
    this.isDcr = false,
    this.almmListed = false,
    this.approvedList = false,
    this.warrantyYears,
    this.unitPrice = 0,
    this.active = true,
  });

  final String id;
  final String companyId;
  final ProductType type;
  final String brand;
  final String model;
  final double? wattPeak;
  final bool isDcr;
  final bool almmListed;
  final bool approvedList;
  final int? warrantyYears;
  final double unitPrice;
  final bool active;

  String get label => '$brand $model';

  /// Panel qualifies for subsidy.
  bool get subsidyEligible => isDcr && almmListed;

  factory Product.fromRow(Map<String, Object?> r) => Product(
    id: r['id']! as String,
    companyId: r['company_id']! as String,
    type: ProductType.values.firstWhere(
      (t) => t.name == r['type'],
      orElse: () => ProductType.other,
    ),
    brand: (r['brand'] as String?) ?? '',
    model: (r['model'] as String?) ?? '',
    wattPeak: _dn(r['watt_peak']),
    isDcr: r['is_dcr'] == 1 || r['is_dcr'] == true,
    almmListed: r['almm_listed'] == 1 || r['almm_listed'] == true,
    approvedList: r['approved_list'] == 1 || r['approved_list'] == true,
    warrantyYears: (r['warranty_years'] as num?)?.toInt(),
    unitPrice: _d(r['unit_price']),
    active: r['active'] != 0 && r['active'] != false,
  );

  Map<String, Object?> toRow() => {
    'type': type.name,
    'brand': brand.trim(),
    'model': model.trim(),
    'watt_peak': wattPeak,
    'is_dcr': isDcr ? 1 : 0,
    'almm_listed': almmListed ? 1 : 0,
    'approved_list': approvedList ? 1 : 0,
    'warranty_years': warrantyYears,
    'unit_price': unitPrice,
    'active': active ? 1 : 0,
  };
}

enum ProposalStatus { draft, sent, signed, expired }

/// Rep-confirmed and override flags stored with the proposal.
class ComplianceState {
  const ComplianceState({
    this.ownConnection = false,
    this.roofType = false,
    this.overrideBy,
  });

  final bool ownConnection;
  final bool roofType;

  /// Owner who allowed sending despite failing checks.
  final String? overrideBy;

  factory ComplianceState.fromJson(Map<String, Object?> j) => ComplianceState(
    ownConnection: j['own_connection'] == true,
    roofType: j['roof_type'] == true,
    overrideBy: j['override_by'] as String?,
  );

  Map<String, Object?> toJson() => {
    'own_connection': ownConnection,
    'roof_type': roofType,
    'override_by': overrideBy,
  };

  ComplianceState copyWith({
    bool? ownConnection,
    bool? roofType,
    String? Function()? overrideBy,
  }) => ComplianceState(
    ownConnection: ownConnection ?? this.ownConnection,
    roofType: roofType ?? this.roofType,
    overrideBy: overrideBy == null ? this.overrideBy : overrideBy(),
  );
}

class LoanTerms {
  const LoanTerms({
    required this.amount,
    required this.rate,
    required this.years,
    required this.emi,
    this.bank,
  });

  final double amount;
  final double rate;
  final int years;
  final double emi;
  final String? bank;

  factory LoanTerms.fromJson(Map<String, Object?> j) => LoanTerms(
    amount: _d(j['amount']),
    rate: _d(j['rate']),
    years: _d(j['years']).round(),
    emi: _d(j['emi']),
    bank: j['bank'] as String?,
  );

  Map<String, Object?> toJson() => {
    'amount': amount,
    'rate': rate,
    'years': years,
    'emi': emi,
    'bank': bank,
  };
}

class Proposal {
  const Proposal({
    required this.id,
    required this.companyId,
    required this.leadId,
    required this.version,
    required this.language,
    required this.systemKw,
    this.panelProductId,
    this.panelCount,
    this.inverterProductId,
    required this.grossPrice,
    required this.centralSubsidy,
    required this.stateSubsidy,
    required this.netPrice,
    this.loan,
    this.monthlyGeneration = const [],
    this.annualSavings,
    this.paybackYears,
    this.lifetimeSavings,
    this.currentMonthlyBill,
    this.compliance = const ComplianceState(),
    this.status = ProposalStatus.draft,
    this.pdfPath,
    this.pdfGeneratedAt,
    this.signaturePng,
    this.signedAt,
    this.sentAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String leadId;
  final int version;
  final String language;
  final double systemKw;
  final String? panelProductId;
  final int? panelCount;
  final String? inverterProductId;
  final double grossPrice;
  final double centralSubsidy;
  final double stateSubsidy;
  final double netPrice;
  final LoanTerms? loan;
  final List<double> monthlyGeneration;
  final double? annualSavings;
  final double? paybackYears;
  final double? lifetimeSavings;
  final double? currentMonthlyBill;
  final ComplianceState compliance;
  final ProposalStatus status;
  final String? pdfPath;
  final DateTime? pdfGeneratedAt;
  final String? signaturePng;
  final DateTime? signedAt;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get totalSubsidy => centralSubsidy + stateSubsidy;
  bool get isEditable => status == ProposalStatus.draft;

  /// The PDF is older than the last change (needs regenerating).
  bool get pdfStale =>
      pdfPath == null ||
      (pdfGeneratedAt != null &&
          updatedAt != null &&
          updatedAt!.isAfter(pdfGeneratedAt!.add(const Duration(seconds: 5))));

  factory Proposal.fromRow(Map<String, Object?> r) {
    final gen = _json(r['est_generation'])['monthly'];
    final loan = _json(r['loan']);
    DateTime? t(String k) => DateTime.tryParse((r[k] as String?) ?? '');
    return Proposal(
      id: r['id']! as String,
      companyId: r['company_id']! as String,
      leadId: r['lead_id']! as String,
      version: (r['version'] as num?)?.toInt() ?? 1,
      language: (r['language'] as String?) ?? 'en',
      systemKw: _d(r['system_kw']),
      panelProductId: r['panel_product_id'] as String?,
      panelCount: (r['panel_count'] as num?)?.toInt(),
      inverterProductId: r['inverter_product_id'] as String?,
      grossPrice: _d(r['gross_price']),
      centralSubsidy: _d(r['central_subsidy']),
      stateSubsidy: _d(r['state_subsidy']),
      netPrice: _d(r['net_price']),
      loan: loan.isEmpty ? null : LoanTerms.fromJson(loan),
      monthlyGeneration: gen is List ? gen.map(_d).toList() : const [],
      annualSavings: _dn(r['annual_savings']),
      paybackYears: _dn(r['payback_years']),
      lifetimeSavings: _dn(r['lifetime_savings']),
      currentMonthlyBill: _dn(r['current_monthly_bill']),
      compliance: ComplianceState.fromJson(_json(r['compliance'])),
      status: ProposalStatus.values.firstWhere(
        (s) => s.name == r['status'],
        orElse: () => ProposalStatus.draft,
      ),
      pdfPath: r['pdf_path'] as String?,
      pdfGeneratedAt: t('pdf_generated_at'),
      signaturePng: r['signature_png'] as String?,
      signedAt: t('signed_at'),
      sentAt: t('sent_at'),
      createdAt: t('created_at'),
      updatedAt: t('updated_at'),
    );
  }
}

/// Everything the builder computes for one draft.
class ProposalDraft {
  const ProposalDraft({
    required this.systemKw,
    required this.language,
    this.panel,
    this.panelCount,
    this.inverter,
    required this.grossPrice,
    required this.subsidy,
    required this.loan,
    required this.monthlyGeneration,
    this.savings,
    this.currentMonthlyBill,
    required this.compliance,
  });

  final double systemKw;
  final String language;
  final Product? panel;
  final int? panelCount;
  final Product? inverter;
  final double grossPrice;
  final SubsidyResult subsidy;
  final LoanTerms loan;
  final List<double> monthlyGeneration;
  final SavingsResult? savings;
  final double? currentMonthlyBill;
  final ComplianceState compliance;

  double get netPrice =>
      (grossPrice - subsidy.total).clamp(0, double.infinity).toDouble();

  Map<String, Object?> toRow() => {
    'language': language,
    'system_kw': systemKw,
    'panel_product_id': panel?.id,
    'panel_count': panelCount,
    'inverter_product_id': inverter?.id,
    'gross_price': grossPrice,
    'central_subsidy': subsidy.central.amount,
    'state_subsidy': subsidy.state.amount,
    'net_price': netPrice,
    'loan': jsonEncode(loan.toJson()),
    'est_generation': jsonEncode({
      'monthly': [for (final m in monthlyGeneration) m.roundToDouble()],
      'annual': monthlyGeneration.fold<double>(0, (a, b) => a + b).round(),
    }),
    'annual_savings': savings?.annualSavingYear1.roundToDouble(),
    'payback_years': savings?.paybackYears == null
        ? null
        : double.parse(savings!.paybackYears!.toStringAsFixed(1)),
    'lifetime_savings': savings?.lifetimeSaving.roundToDouble(),
    'current_monthly_bill': currentMonthlyBill?.roundToDouble(),
    'compliance': jsonEncode(compliance.toJson()),
  };
}

enum PaymentStatus { created, paid, expired, cancelled }

class Payment {
  const Payment({
    required this.id,
    required this.proposalId,
    required this.kind,
    required this.amount,
    required this.status,
    this.shortUrl,
    this.paidAt,
  });

  final String id;
  final String proposalId;
  final String kind;
  final double amount;
  final PaymentStatus status;
  final String? shortUrl;
  final DateTime? paidAt;

  factory Payment.fromRow(Map<String, Object?> r) => Payment(
    id: r['id']! as String,
    proposalId: r['proposal_id']! as String,
    kind: (r['kind'] as String?) ?? 'advance',
    amount: _d(r['amount']),
    status: PaymentStatus.values.firstWhere(
      (s) => s.name == r['status'],
      orElse: () => PaymentStatus.created,
    ),
    shortUrl: r['short_url'] as String?,
    paidAt: DateTime.tryParse((r['paid_at'] as String?) ?? ''),
  );
}

/// Fills `{placeholder}` values in a WhatsApp template.
String fillTemplate(String template, Map<String, String> values) =>
    template.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (m) => values[m.group(1)] ?? m.group(0)!,
    );
