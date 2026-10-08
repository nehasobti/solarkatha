import 'dart:math' as math;

class LoanResult {
  const LoanResult({
    required this.principal,
    required this.annualRatePct,
    required this.months,
    required this.emi,
  });

  final double principal;
  final double annualRatePct;
  final int months;
  final double emi;

  double get totalPayable => emi * months;
  double get totalInterest => totalPayable - principal;
}

/// EMI = P × r × (1+r)^n ÷ ((1+r)^n − 1), r = annual rate ÷ 12, n = months.
/// A 0% rate gives P ÷ n.
LoanResult calculateEmi({
  required double principal,
  required double annualRatePct,
  required int months,
}) {
  if (months <= 0) throw ArgumentError.value(months, 'months');
  if (principal < 0) throw ArgumentError.value(principal, 'principal');
  if (annualRatePct < 0) {
    throw ArgumentError.value(annualRatePct, 'annualRatePct');
  }
  final r = annualRatePct / 12 / 100;
  final emi = r == 0
      ? principal / months
      : principal * r * math.pow(1 + r, months) / (math.pow(1 + r, months) - 1);
  return LoanResult(
    principal: principal,
    annualRatePct: annualRatePct,
    months: months,
    emi: emi,
  );
}

/// A row of `loan_presets`.
class LoanPreset {
  const LoanPreset({
    required this.id,
    required this.bankName,
    required this.ratePct,
    required this.maxYears,
    this.notes,
  });

  final String id;
  final String bankName;
  final double ratePct;
  final int maxYears;
  final String? notes;
}
