import 'package:solar_core/solar_core.dart';

/// Values seeded in the database (supabase/seed.sql) at build time.
const centralRule = SubsidyRule(
  slabs: [
    SubsidySlab(uptoKw: 2, perKw: 30000),
    SubsidySlab(uptoKw: 3, perKw: 18000),
  ],
  capAmount: 78000,
);

const upStateRule = SubsidyRule(
  slabs: [SubsidySlab(uptoKw: null, perKw: 15000)],
  capAmount: 30000,
);

const config = SolarConfig(
  sqmPerKw: 10,
  defaultYieldKwhPerKwDay: 4.2,
  shadingLossPct: {
    ShadingLevel.none: 0,
    ShadingLevel.low: 3,
    ShadingLevel.medium: 8,
    ShadingLevel.high: 15,
  },
  degradationPctPerYear: 0.5,
  tariffEscalationPctPerYear: 3,
  exportRatePerKwh: 2,
  lifetimeYears: 25,
  pricePerKw: 60000,
);

const simpleTariff = Tariff(
  slabs: [
    TariffSlab(uptoUnits: 100, rate: 5),
    TariffSlab(uptoUnits: 300, rate: 6),
    TariffSlab(uptoUnits: null, rate: 7),
  ],
  fixedCharge: 110,
);
