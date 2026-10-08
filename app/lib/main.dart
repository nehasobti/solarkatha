import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env.dart';
import 'core/preferences/app_preferences.dart';
import 'data/powersync/powersync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean web URLs (/t/<token>, /dashboard) instead of /#/...
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();
  final prefsOverride = sharedPreferencesProvider.overrideWithValue(prefs);

  if (!Env.isConfigured) {
    runApp(
      ProviderScope(
        overrides: [prefsOverride],
        child: const ConfigMissingApp(),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  final local = await LocalData.open();

  runApp(
    ProviderScope(
      overrides: [prefsOverride, localDataProvider.overrideWithValue(local)],
      child: const SolarKathaApp(),
    ),
  );
}
