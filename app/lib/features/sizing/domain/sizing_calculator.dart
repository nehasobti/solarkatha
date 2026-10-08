import 'dart:math' as math;

import 'package:solar_core/solar_core.dart';

import 'sizing_config.dart';

/// Inputs the rep controls on the sizing screen.
class SizingInputs {
  const SizingInputs({
    required this.avgMonthlyUnits,
    required this.monthlyPerKw,
    this.history12,
    this.sanctionedLoadKw,
    this.roofAreaSqm,
    this.shading = ShadingLevel.none,
    this.panelsEligible = true,
    this.stateCode,
    this.discom,
    this.billAmount,
    this.pricePerKw,
    this.loanRatePct,
    this.loanYears,
  });

  final double avgMonthlyUnits;
  final List<double> monthlyPerKw;
  final List<double>? history12;
  final double? sanctionedLoadKw;
  final double? roofAreaSqm;
  final ShadingLevel shading;
  final bool panelsEligible;
  final String? stateCode;
  final String? discom;
  final double? billAmount;
  final double? pricePerKw;
  final double? loanRatePct;
  final int? loanYears;
}

/// Everything shown for one system size.
class SizingOption {
  const SizingOption({
    required this.kw,
    required this.generation,
    required this.subsidy,
    required this.grossPrice,
    required this.loan,
    required this.savings,
  });

  final double kw;
  final List<double> generation;
  final SubsidyResult subsidy;
  final double grossPrice;
  final LoanResult loan;

  /// Null when there is no tariff and no bill amount to value savings.
  final SavingsResult? savings;

  double get annualKwh => sum(generation);
  double get monthlyKwh => annualKwh / 12;
  double get netPrice => math.max(0, grossPrice - subsidy.total);
}

enum TariffSource { configured, fromBill, none }

/// Combines `solar_core` calculations for the sizing screen.
class SizingCalculator {
  SizingCalculator(this.config, this.inputs)
    : usage = usageProfile(
        avgMonthlyUnits: inputs.avgMonthlyUnits,
        history: inputs.history12,
      ) {
    final configured = config.tariffFor(inputs.stateCode, inputs.discom);
    if (configured != null) {
      tariff = configured;
      tariffSource = TariffSource.configured;
    } else if ((inputs.billAmount ?? 0) > 0 && inputs.avgMonthlyUnits > 0) {
      // No tariff for this state: value units at the bill's average rate.
      tariff = Tariff(
        slabs: [
          TariffSlab(
            uptoUnits: null,
            rate: inputs.billAmount! / inputs.avgMonthlyUnits,
          ),
        ],
      );
      tariffSource = TariffSource.fromBill;
    } else {
      tariff = null;
      tariffSource = TariffSource.none;
    }
  }

  final SizingConfig config;
  final SizingInputs inputs;
  final List<double> usage;
  late final Tariff? tariff;
  late final TariffSource tariffSource;

  SolarConfig get solar => config.solar;

  late final SizingResult sizing = recommendSize(
    avgMonthlyUnits: inputs.avgMonthlyUnits,
    monthlyPerKw: inputs.monthlyPerKw,
    sqmPerKw: solar.sqmPerKw,
    sanctionedLoadKw: inputs.sanctionedLoadKw,
    usableAreaSqm: inputs.roofAreaSqm,
  );

  double get pricePerKw => inputs.pricePerKw ?? solar.pricePerKw;

  LoanPreset? get defaultLoan => config.loans.firstOrNull;
  double get loanRatePct => inputs.loanRatePct ?? defaultLoan?.ratePct ?? 0;
  int get loanYears => inputs.loanYears ?? defaultLoan?.maxYears ?? 5;

  /// Today's monthly bill: as printed, else from the tariff.
  double? get currentMonthlyBill =>
      inputs.billAmount ?? tariff?.monthlyBill(inputs.avgMonthlyUnits);

  SizingOption evaluate(double kw, {double? loanAmount}) {
    final generation = monthlyGeneration(
      kw: kw,
      monthlyPerKw: inputs.monthlyPerKw,
      shading: inputs.shading,
      config: solar,
    );
    final subsidy = calculateSubsidy(
      kw: kw,
      central: config.central,
      state: config.stateRule(inputs.stateCode),
      panelsEligible: inputs.panelsEligible,
    );
    final gross = kw * pricePerKw;
    final net = math.max(0.0, gross - subsidy.total);
    final loan = calculateEmi(
      principal: loanAmount ?? net,
      annualRatePct: loanRatePct,
      months: loanYears * 12,
    );
    final t = tariff;
    return SizingOption(
      kw: kw,
      generation: generation,
      subsidy: subsidy,
      grossPrice: gross,
      loan: loan,
      savings: t == null
          ? null
          : projectSavings(
              monthlyUsage: usage,
              monthlyGenerationYear1: generation,
              tariff: t,
              exportRate: solar.exportRatePerKwh,
              escalationPctPerYear: solar.tariffEscalationPctPerYear,
              degradationPctPerYear: solar.degradationPctPerYear,
              years: solar.lifetimeYears,
              netPrice: net,
            ),
    );
  }
}
