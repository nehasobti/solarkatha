/// Build-time configuration, passed with `--dart-define-from-file=env/<env>.json`.
///
/// Only public values belong here (Supabase URL and publishable (or legacy anon) key,
/// PowerSync URL, a domain-restricted Maps key). Server secrets never reach
/// the app.
abstract final class Env {
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const powersyncUrl = String.fromEnvironment('POWERSYNC_URL');
  static const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
