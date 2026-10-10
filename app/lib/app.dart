import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/l10n.dart';
import 'core/preferences/app_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/empty_state.dart';
import 'data/powersync/powersync_providers.dart';
import 'data/push/push_service.dart';
import 'features/bills/application/scan_processor.dart';
import 'features/auth/application/app_session.dart';
import 'features/auth/application/session_controller.dart';

const _localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Applies language, high contrast and large text to any MaterialApp.
TransitionBuilder _displayBuilder(AppPreferences prefs) => (context, child) {
  if (!prefs.largeText) return child!;
  final scaler = MediaQuery.textScalerOf(context);
  return MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(scaler.scale(1) * 1.25)),
    child: child!,
  );
};

class SolarKathaApp extends ConsumerWidget {
  const SolarKathaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesControllerProvider);
    final router = ref.watch(appRouterProvider);
    // Connects/disconnects offline sync as users sign in and out.
    ref.watch(syncControllerProvider);
    // Runs bill scans queued while offline.
    ref.watch(scanProcessorProvider);

    // The profile's language wins when a user signs in on a new device.
    ref.listen(sessionControllerProvider, (previous, next) {
      final was = previous?.value;
      final now = next.value;
      if (now is Ready && (was is! Ready || was.profile.id != now.profile.id)) {
        ref
            .read(appPreferencesControllerProvider.notifier)
            .setLanguage(now.profile.language)
            .ignore();
      }
      // Phone notifications for this member; a tap opens the project.
      if (now is Ready && now.profile.active) {
        ref
            .read(pushServiceProvider)
            .start(profileId: now.profile.id, onOpen: router.push)
            .ignore();
      }
    });

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: prefs.highContrast),
      darkTheme: AppTheme.dark(highContrast: prefs.highContrast),
      themeMode: prefs.highContrast ? ThemeMode.light : ThemeMode.system,
      locale: Locale(prefs.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _localizationsDelegates,
      routerConfig: router,
      builder: _displayBuilder(prefs),
    );
  }
}

/// Shown when the build has no Supabase configuration.
class ConfigMissingApp extends ConsumerWidget {
  const ConfigMissingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesControllerProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: prefs.highContrast),
      locale: Locale(prefs.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _localizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: EmptyState(
            icon: Icons.settings_suggest_outlined,
            title: context.l10n.configMissingTitle,
            body: context.l10n.configMissingBody,
          ),
        ),
      ),
    );
  }
}
