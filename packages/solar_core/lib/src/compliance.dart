/// PM Surya Ghar compliance checklist. A proposal can be sent only when
/// every blocking item passes, or an owner overrides.
enum ComplianceCheck {
  panelsDcr,
  panelsAlmm,
  inverterApproved,
  ownConnection,
  consumerNumber,
  roofPhotos,
  roofType,
  singleSubsidy,
}

class ComplianceInput {
  const ComplianceInput({
    required this.panelsDcr,
    required this.panelsAlmm,
    required this.inverterApproved,
    required this.ownConnectionConfirmed,
    required this.consumerNumber,
    required this.photoCount,
    required this.roofTypeRecorded,
    required this.duplicateConsumerLeads,
    this.minPhotos = 4,
  });

  final bool panelsDcr;
  final bool panelsAlmm;
  final bool inverterApproved;

  /// Rep confirms the connection is in the customer's own name.
  final bool ownConnectionConfirmed;
  final String? consumerNumber;
  final int photoCount;

  /// Roof type saved in the survey.
  final bool roofTypeRecorded;

  /// Other leads in the company with the same consumer number.
  final int duplicateConsumerLeads;
  final int minPhotos;
}

class ComplianceItem {
  const ComplianceItem(this.check, {required this.passed, this.manual = false});

  final ComplianceCheck check;
  final bool passed;

  /// The rep ticks this item; it cannot be checked automatically.
  final bool manual;
}

class ComplianceResult {
  const ComplianceResult(this.items, {this.overridden = false});

  final List<ComplianceItem> items;

  /// An owner allowed sending despite failures.
  final bool overridden;

  bool get allPassed => items.every((i) => i.passed);
  bool get canSend => allPassed || overridden;
  List<ComplianceItem> get failing => items.where((i) => !i.passed).toList();
}

ComplianceResult evaluateCompliance(
  ComplianceInput input, {
  bool ownerOverride = false,
}) {
  final consumer = input.consumerNumber?.trim() ?? '';
  return ComplianceResult([
    ComplianceItem(ComplianceCheck.panelsDcr, passed: input.panelsDcr),
    ComplianceItem(ComplianceCheck.panelsAlmm, passed: input.panelsAlmm),
    ComplianceItem(
      ComplianceCheck.inverterApproved,
      passed: input.inverterApproved,
    ),
    ComplianceItem(
      ComplianceCheck.ownConnection,
      passed: input.ownConnectionConfirmed,
      manual: true,
    ),
    ComplianceItem(
      ComplianceCheck.consumerNumber,
      passed: consumer.length >= 4,
    ),
    ComplianceItem(
      ComplianceCheck.roofPhotos,
      passed: input.photoCount >= input.minPhotos,
    ),
    ComplianceItem(
      ComplianceCheck.roofType,
      passed: input.roofTypeRecorded,
    ),
    ComplianceItem(
      ComplianceCheck.singleSubsidy,
      passed: input.duplicateConsumerLeads == 0,
    ),
  ], overridden: ownerOverride);
}

/// Panels needed for [kw] with [wattPeak] modules (rounded up).
int panelCount(double kw, double wattPeak) {
  if (kw <= 0 || wattPeak <= 0) return 0;
  return (kw * 1000 / wattPeak - 1e-9).ceil();
}

/// kW actually installed with [count] panels of [wattPeak].
double installedKw(int count, double wattPeak) => count * wattPeak / 1000;
