import 'dart:math' as math;

/// One slab of a subsidy rule: [perKw] rupees for each kW up to [uptoKw]
/// (cumulative system size). A null [uptoKw] means "no upper limit".
class SubsidySlab {
  const SubsidySlab({required this.uptoKw, required this.perKw});

  final double? uptoKw;
  final double perKw;

  factory SubsidySlab.fromJson(Map<String, Object?> json) => SubsidySlab(
    uptoKw: (json['upto_kw'] as num?)?.toDouble(),
    perKw: (json['per_kw'] as num).toDouble(),
  );
}

/// A row of `subsidy_rules`: slabs plus an optional overall cap.
class SubsidyRule {
  const SubsidyRule({required this.slabs, this.capAmount});

  final List<SubsidySlab> slabs;
  final double? capAmount;
}

/// One line of the per-kW explanation shown to the customer.
class SubsidyLine {
  const SubsidyLine({
    required this.fromKw,
    required this.toKw,
    required this.perKw,
    required this.amount,
  });

  final double fromKw;
  final double toKw;
  final double perKw;
  final double amount;
}

class RuleAmount {
  const RuleAmount({
    required this.amount,
    required this.lines,
    required this.capped,
  });

  final double amount;
  final List<SubsidyLine> lines;

  /// The cap reduced the amount.
  final bool capped;

  static const zero = RuleAmount(amount: 0, lines: [], capped: false);
}

/// Applies one rule to a [kw] system.
RuleAmount applyRule(SubsidyRule rule, double kw) {
  if (kw <= 0) return RuleAmount.zero;
  final lines = <SubsidyLine>[];
  var from = 0.0;
  var total = 0.0;
  for (final slab in rule.slabs) {
    if (from >= kw) break;
    final to = math.min(kw, slab.uptoKw ?? double.infinity);
    if (to <= from) continue;
    final amount = (to - from) * slab.perKw;
    if (amount > 0) {
      lines.add(
        SubsidyLine(fromKw: from, toKw: to, perKw: slab.perKw, amount: amount),
      );
    }
    total += amount;
    from = to;
  }
  final cap = rule.capAmount;
  final capped = cap != null && total > cap;
  return RuleAmount(amount: capped ? cap : total, lines: lines, capped: capped);
}

class SubsidyResult {
  const SubsidyResult({
    required this.eligible,
    required this.central,
    required this.state,
  });

  /// Panels are DCR and ALMM-listed. When false, subsidy is ₹0.
  final bool eligible;
  final RuleAmount central;
  final RuleAmount state;

  double get total => central.amount + state.amount;

  /// Average subsidy per kW, to explain the cap.
  double perKw(double kw) => kw <= 0 ? 0 : total / kw;
}

/// Central + state subsidy for a residential [kw] system. Subsidy applies
/// only to DCR, ALMM-listed panels ([panelsEligible]).
SubsidyResult calculateSubsidy({
  required double kw,
  required SubsidyRule central,
  SubsidyRule? state,
  required bool panelsEligible,
}) {
  if (!panelsEligible) {
    return const SubsidyResult(
      eligible: false,
      central: RuleAmount.zero,
      state: RuleAmount.zero,
    );
  }
  return SubsidyResult(
    eligible: true,
    central: applyRule(central, kw),
    state: state == null ? RuleAmount.zero : applyRule(state, kw),
  );
}
