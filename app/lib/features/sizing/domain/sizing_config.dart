import 'dart:convert';

import 'package:solar_core/solar_core.dart';

/// Everything sizing needs from the config tables, resolved for one company
/// (company rows override the platform defaults).
class SizingConfig {
  const SizingConfig({
    required this.solar,
    required this.central,
    required this.stateRules,
    required this.tariffs,
    required this.loans,
  });

  final SolarConfig solar;
  final SubsidyRule central;
  final Map<String, SubsidyRule> stateRules;
  final List<TariffEntry> tariffs;
  final List<LoanPreset> loans;

  SubsidyRule? stateRule(String? stateCode) =>
      stateCode == null ? null : stateRules[stateCode];

  /// Tariff for the customer's state, preferring an exact DISCOM match.
  Tariff? tariffFor(String? stateCode, String? discom) {
    final inState = tariffs.where((t) => t.stateCode == stateCode).toList();
    final d = discom?.trim().toUpperCase();
    return (inState
                .where((t) => d != null && t.discom?.toUpperCase() == d)
                .firstOrNull ??
            inState.where((t) => t.discom == null).firstOrNull)
        ?.tariff;
  }

  /// Builds the config from raw device rows. Throws [FormatException] when a
  /// required setting is missing (e.g. config not synced yet).
  factory SizingConfig.fromRows({
    required String companyId,
    required List<Map<String, Object?>> appConfig,
    required List<Map<String, Object?>> subsidyRules,
    required List<Map<String, Object?>> tariffs,
    required List<Map<String, Object?>> loanPresets,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    bool mine(Map<String, Object?> r) => r['company_id'] == companyId;
    bool usable(Map<String, Object?> r) => r['company_id'] == null || mine(r);

    // app_config: company value wins over the default.
    final values = <String, Object?>{};
    for (final r
        in appConfig.where(usable).toList()
          ..sort((a, b) => mine(a) ? 1 : (mine(b) ? -1 : 0))) {
      values[r['key']! as String] = _decode(r['value']);
    }

    // Subsidy rules valid today, residential; company rows win per scope.
    final rules = <String, SubsidyRule>{};
    final ruleOwner = <String, bool>{};
    for (final r in subsidyRules.where(usable)) {
      if ((r['segment'] ?? 'residential') != 'residential') continue;
      final from = DateTime.tryParse((r['valid_from'] as String?) ?? '');
      final to = DateTime.tryParse((r['valid_to'] as String?) ?? '');
      if (from != null && from.isAfter(now)) continue;
      if (to != null && to.isBefore(now)) continue;
      final scope = r['scope']! as String;
      if (ruleOwner[scope] == true && !mine(r)) continue;
      rules[scope] = SubsidyRule(
        slabs: [
          for (final s in _decode(r['slabs']) as List<Object?>)
            SubsidySlab.fromJson((s! as Map).cast<String, Object?>()),
        ],
        capAmount: (r['cap_amount'] as num?)?.toDouble(),
      );
      ruleOwner[scope] = mine(r);
    }
    final central = rules.remove('central');
    if (central == null) {
      throw const FormatException('No central subsidy rule');
    }

    final tariffEntries = [
      for (final r
          in tariffs.where(usable).toList()
            ..sort((a, b) => mine(a) ? -1 : (mine(b) ? 1 : 0)))
        TariffEntry(
          stateCode: r['state_code']! as String,
          discom: r['discom'] as String?,
          tariff: Tariff(
            slabs: [
              for (final s in _decode(r['slabs']) as List<Object?>)
                TariffSlab.fromJson((s! as Map).cast<String, Object?>()),
            ],
            fixedCharge: (r['fixed_charge'] as num?)?.toDouble() ?? 0,
          ),
        ),
    ];

    final loans = [
      for (final r
          in loanPresets.where(usable).toList()..sort(
            (a, b) =>
                ((a['sort'] as int?) ?? 0).compareTo((b['sort'] as int?) ?? 0),
          ))
        LoanPreset(
          id: r['id']! as String,
          bankName: r['bank_name']! as String,
          ratePct: (r['rate_pct']! as num).toDouble(),
          maxYears: (r['max_years']! as num).toInt(),
          notes: r['notes'] as String?,
        ),
    ];

    return SizingConfig(
      solar: SolarConfig.fromMap(values),
      central: central,
      stateRules: rules,
      tariffs: tariffEntries,
      loans: loans,
    );
  }
}

class TariffEntry {
  const TariffEntry({
    required this.stateCode,
    required this.discom,
    required this.tariff,
  });

  final String stateCode;
  final String? discom;
  final Tariff tariff;
}

Object? _decode(Object? v) {
  if (v is String) {
    try {
      return jsonDecode(v);
    } catch (_) {
      return v;
    }
  }
  return v;
}
