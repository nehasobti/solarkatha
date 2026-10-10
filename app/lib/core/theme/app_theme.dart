import 'package:flutter/material.dart';

/// SolarKatha brand colours: clean white surfaces, navy ink, solar orange for
/// actions, green for "done".
abstract final class Brand {
  static const orange = Color(0xFFEA580C); // buttons, selected states
  static const amber = Color(0xFFF59E0B); // highlights, sun
  static const orangeSoft = Color(0xFFFFEDD5); // selected backgrounds
  static const navy = Color(0xFF0F1B2D); // text, headings
  static const slate = Color(0xFF5B6779); // secondary text
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0xFFDBEAFE);
  static const red = Color(0xFFDC2626);
  static const background = Color(0xFFF7F8FA);
  static const field = Color(0xFFF1F3F6);
  static const line = Color(0xFFE3E7ED);
}

/// SolarKatha themes. Built for outdoor use on low-end phones: large touch
/// targets, clear contrast, and a high-contrast variant for bright sunlight.
abstract final class AppTheme {
  static const brandSeed = Brand.orange;

  static const _fontFamily = 'NotoSans';
  static const _fontFallback = ['NotoSansDevanagari'];

  static ThemeData light({bool highContrast = false}) {
    final scheme =
        const ColorScheme(
          brightness: Brightness.light,
          primary: Brand.orange,
          onPrimary: Colors.white,
          primaryContainer: Brand.orangeSoft,
          onPrimaryContainer: Color(0xFF7C2D12),
          secondary: Brand.navy,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFE8ECF2),
          onSecondaryContainer: Brand.navy,
          tertiary: Brand.green,
          onTertiary: Colors.white,
          tertiaryContainer: Brand.greenSoft,
          onTertiaryContainer: Color(0xFF14532D),
          error: Brand.red,
          onError: Colors.white,
          errorContainer: Color(0xFFFEE2E2),
          onErrorContainer: Color(0xFF7F1D1D),
          surface: Colors.white,
          onSurface: Brand.navy,
          onSurfaceVariant: Brand.slate,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: Color(0xFFFAFBFC),
          surfaceContainer: Brand.background,
          surfaceContainerHigh: Brand.field,
          surfaceContainerHighest: Color(0xFFE9ECF1),
          outline: Color(0xFFB8C0CC),
          outlineVariant: Brand.line,
          inverseSurface: Brand.navy,
          onInverseSurface: Colors.white,
          inversePrimary: Color(0xFFFDBA74),
          shadow: Color(0xFF0F1B2D),
          surfaceTint: Colors.transparent,
        ).copyWith(
          surface: highContrast ? Colors.white : null,
          onSurface: highContrast ? Colors.black : null,
          onSurfaceVariant: highContrast ? Colors.black : null,
          outline: highContrast ? Colors.black : null,
          outlineVariant: highContrast ? Colors.black : null,
          primary: highContrast ? const Color(0xFFB03F00) : null,
        );
    return _build(
      scheme,
      highContrast: highContrast,
      scaffold: highContrast ? Colors.white : Brand.background,
    );
  }

  static ThemeData dark({bool highContrast = false}) {
    final scheme =
        const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFFB923C),
          onPrimary: Color(0xFF1A0E05),
          primaryContainer: Color(0xFF4A2410),
          onPrimaryContainer: Color(0xFFFFEDD5),
          secondary: Color(0xFFCBD5E1),
          onSecondary: Brand.navy,
          secondaryContainer: Color(0xFF233247),
          onSecondaryContainer: Color(0xFFE2E8F0),
          tertiary: Color(0xFF4ADE80),
          onTertiary: Color(0xFF052E16),
          tertiaryContainer: Color(0xFF14532D),
          onTertiaryContainer: Brand.greenSoft,
          error: Color(0xFFF87171),
          onError: Color(0xFF450A0A),
          errorContainer: Color(0xFF7F1D1D),
          onErrorContainer: Color(0xFFFEE2E2),
          surface: Color(0xFF131E2E),
          onSurface: Color(0xFFF1F5F9),
          onSurfaceVariant: Color(0xFF9AA8BB),
          surfaceContainerLowest: Color(0xFF0B1320),
          surfaceContainerLow: Color(0xFF111A28),
          surfaceContainer: Color(0xFF0E1726),
          surfaceContainerHigh: Color(0xFF1C2838),
          surfaceContainerHighest: Color(0xFF243246),
          outline: Color(0xFF55657A),
          outlineVariant: Color(0xFF243246),
          inverseSurface: Color(0xFFF1F5F9),
          onInverseSurface: Brand.navy,
          inversePrimary: Brand.orange,
          shadow: Colors.black,
          surfaceTint: Colors.transparent,
        ).copyWith(
          surface: highContrast ? Colors.black : null,
          onSurface: highContrast ? Colors.white : null,
          onSurfaceVariant: highContrast ? Colors.white : null,
          outline: highContrast ? Colors.white : null,
          outlineVariant: highContrast ? Colors.white : null,
        );
    return _build(
      scheme,
      highContrast: highContrast,
      scaffold: highContrast ? Colors.black : const Color(0xFF0E1726),
    );
  }

  static ThemeData _build(
    ColorScheme scheme, {
    required bool highContrast,
    required Color scaffold,
  }) {
    const minTap = Size(64, 52);
    final borderWidth = highContrast ? 2.0 : 1.0;
    final radius = BorderRadius.circular(12);
    final light = scheme.brightness == Brightness.light;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
    );
    final text = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerColor: scheme.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        bodySmall: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        labelSmall: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: light ? Colors.white : scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: scheme.onSurface,
        ),
        shape: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: borderWidth),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minTap,
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: minTap,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minTap,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline, width: borderWidth),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: highContrast
            ? scheme.surface
            : (light ? Brand.field : scheme.surfaceContainerHigh),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: highContrast
              ? BorderSide(color: scheme.outline, width: borderWidth)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: scheme.shadow.withValues(alpha: 0.06),
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant, width: borderWidth),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant, width: borderWidth),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outlineVariant, width: borderWidth),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: light ? Colors.white : scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: s.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: light ? Colors.white : scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        iconColor: scheme.onSurfaceVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : null,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    );
  }
}
