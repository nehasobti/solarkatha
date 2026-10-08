import 'dart:convert';

import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_core/solar_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/preferences/app_preferences.dart';
import '../../../data/powersync/powersync_providers.dart';
import '../../../data/supabase/supabase_providers.dart';
import '../../leads/application/leads_providers.dart';
import '../domain/sizing_config.dart';

part 'sizing_repository.g.dart';

const _configTables = {
  'app_config',
  'subsidy_rules',
  'tariffs',
  'loan_presets',
};

/// Sizing settings from the device database, live.
Stream<SizingConfig?> watchSizingConfig(
  PowerSyncDatabase db,
  String companyId,
) => db
    .watch('SELECT COUNT(*) FROM app_config', triggerOnTables: _configTables)
    .asyncMap((_) async {
      try {
        return SizingConfig.fromRows(
          companyId: companyId,
          appConfig: await db.getAll('SELECT * FROM app_config'),
          subsidyRules: await db.getAll('SELECT * FROM subsidy_rules'),
          tariffs: await db.getAll('SELECT * FROM tariffs'),
          loanPresets: await db.getAll('SELECT * FROM loan_presets'),
        );
      } on FormatException {
        return null; // not synced yet
      }
    });

@riverpod
Stream<SizingConfig?> sizingConfig(Ref ref) {
  final member = ref.watch(currentMemberProvider);
  if (member == null) return Stream.value(null);
  return watchSizingConfig(ref.watch(powerSyncDbProvider), member.company.id);
}

/// Monthly generation per kW and where it came from.
class GenerationEstimate {
  const GenerationEstimate(this.monthlyPerKw, {required this.fromPvgis});

  final List<double> monthlyPerKw;
  final bool fromPvgis;
}

/// PVGIS via the `generation-estimate` function, remembered on the device
/// per rounded location; falls back to the configured flat yield.
class GenerationService {
  GenerationService(this._client, this._prefs);

  final SupabaseClient _client;
  final SharedPreferences _prefs;

  static String _key(double lat, double lng) =>
      'gen.${(lat * 20).round()}.${(lng * 20).round()}';

  Future<GenerationEstimate> estimate({
    required double? lat,
    required double? lng,
    required SolarConfig config,
  }) async {
    final fallback = GenerationEstimate(
      fallbackMonthlyPerKw(config.defaultYieldKwhPerKwDay),
      fromPvgis: false,
    );
    if (lat == null || lng == null) return fallback;

    final cached = _prefs.getString(_key(lat, lng));
    if (cached != null) {
      final list = (jsonDecode(cached) as List<Object?>)
          .map((v) => (v! as num).toDouble())
          .toList();
      if (list.length == 12) return GenerationEstimate(list, fromPvgis: true);
    }
    try {
      final res = await _client.functions
          .invoke(
            'generation-estimate',
            body: {'lat': lat, 'lng': lng, 'kw': 1},
          )
          .timeout(const Duration(seconds: 15));
      final data = (res.data as Map).cast<String, Object?>();
      final perKw = (data['monthly_kwh_per_kw']! as List<Object?>)
          .map((v) => (v! as num).toDouble())
          .toList();
      final fromPvgis = data['source'] != 'fallback';
      if (fromPvgis && perKw.length == 12) {
        await _prefs.setString(_key(lat, lng), jsonEncode(perKw));
      }
      return GenerationEstimate(perKw, fromPvgis: fromPvgis);
    } catch (_) {
      return fallback; // offline or function unavailable
    }
  }
}

@Riverpod(keepAlive: true)
GenerationService generationService(Ref ref) => GenerationService(
  ref.watch(supabaseClientProvider),
  ref.watch(sharedPreferencesProvider),
);
