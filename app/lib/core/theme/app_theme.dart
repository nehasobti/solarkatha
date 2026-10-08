import 'package:flutter/material.dart';

/// SolarKatha themes. Built for outdoor use on low-end phones: large touch
/// targets, filled inputs, and a high-contrast variant for bright sunlight.
abstract final class AppTheme {
  static const brandSeed = Color(0xFFE07B00);

  static const _fontFamily = 'NotoSans';
  static const _fontFallback = ['NotoSansDevanagari'];

  static ThemeData light({bool highContrast = false}) {
    final scheme = highContrast
        ? ColorScheme.fromSeed(seedColor: brandSeed, contrastLevel: 1).copyWith(
            surface: Colors.white,
            onSurface: Colors.black,
            onSurfaceVariant: Colors.black,
            outline: Colors.black,
          )
        : ColorScheme.fromSeed(seedColor: brandSeed);
    return _build(scheme, highContrast: highContrast);
  }

  static ThemeData dark({bool highContrast = false}) {
    final scheme = highContrast
        ? ColorScheme.fromSeed(
            seedColor: brandSeed,
            brightness: Brightness.dark,
            contrastLevel: 1,
          ).copyWith(
            surface: Colors.black,
            onSurface: Colors.white,
            onSurfaceVariant: Colors.white,
            outline: Colors.white,
          )
        : ColorScheme.fromSeed(
            seedColor: brandSeed,
            brightness: Brightness.dark,
          );
    return _build(scheme, highContrast: highContrast);
  }

  static ThemeData _build(ColorScheme scheme, {required bool highContrast}) {
    const minTap = Size(64, 52);
    final borderWidth = highContrast ? 2.0 : 1.0;
    final radius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minTap,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minTap,
          side: BorderSide(color: scheme.outline, width: borderWidth),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outline, width: borderWidth),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant, width: borderWidth),
        ),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
    );
  }
}
