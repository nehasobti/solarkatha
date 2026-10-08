import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_preferences.freezed.dart';
part 'app_preferences.g.dart';

/// Overridden in `main()` with the loaded instance.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('sharedPreferencesProvider must be overridden');

const supportedLanguageCodes = ['en', 'hi'];

/// Device-level display preferences, available before login.
@freezed
abstract class AppPreferences with _$AppPreferences {
  const factory AppPreferences({
    @Default('en') String languageCode,
    @Default(false) bool highContrast,
    @Default(false) bool largeText,
  }) = _AppPreferences;
}

@Riverpod(keepAlive: true)
class AppPreferencesController extends _$AppPreferencesController {
  static const _kLanguage = 'pref.language';
  static const _kHighContrast = 'pref.highContrast';
  static const _kLargeText = 'pref.largeText';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final lang = prefs.getString(_kLanguage);
    return AppPreferences(
      languageCode: supportedLanguageCodes.contains(lang) ? lang! : 'en',
      highContrast: prefs.getBool(_kHighContrast) ?? false,
      largeText: prefs.getBool(_kLargeText) ?? false,
    );
  }

  Future<void> setLanguage(String code) async {
    if (!supportedLanguageCodes.contains(code) || state.languageCode == code) {
      return;
    }
    state = state.copyWith(languageCode: code);
    await _prefs.setString(_kLanguage, code);
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    await _prefs.setBool(_kHighContrast, value);
  }

  Future<void> setLargeText(bool value) async {
    state = state.copyWith(largeText: value);
    await _prefs.setBool(_kLargeText, value);
  }
}
