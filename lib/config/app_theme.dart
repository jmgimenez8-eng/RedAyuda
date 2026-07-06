import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------------
/// RedAyuda · Design System
/// Estilo: Material 3 "Expressive" + glass selectivo · Paleta "Azul Fintech"
/// Tipografía: Plus Jakarta Sans (titulares) + Inter (cuerpo)
/// Soporta tema claro y oscuro.
/// ---------------------------------------------------------------------------

class AppColors {
  AppColors._();

  // --- Marca -------------------------------------------------------------
  static const Color primary = Color(0xFF4263EB); // Índigo "fintech"
  static const Color accent = Color(0xFFFAB005); // Ámbar / oro (destacados)
  static const Color positive = Color(0xFF12B886); // Esmeralda (dinero/éxito)
  static const Color paypalBlue = Color(0xFF003087);

  // --- Semánticos --------------------------------------------------------
  static const Color success = Color(0xFF12B886);
  static const Color warning = Color(0xFFF76707);
  static const Color error = Color(0xFFE03131);
  static const Color info = Color(0xFF4DABF7);
  static const Color amber = Color(0xFFFAB005); // Estrellas de valoración

  // --- Neutrales (claro) -------------------------------------------------
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDF0F7);
  static const Color outline = Color(0xFFDEE2F0);
  static const Color textPrimary = Color(0xFF11183A);
  static const Color textSecondary = Color(0xFF5B6478);

  // --- Neutrales (oscuro) ------------------------------------------------
  static const Color darkPrimary = Color(0xFF748FFC);
  static const Color darkBackground = Color(0xFF0F1320);
  static const Color darkSurface = Color(0xFF161A24);
  static const Color darkSurfaceVariant = Color(0xFF1F2533);
  static const Color darkOutline = Color(0xFF2A3142);
  static const Color darkTextPrimary = Color(0xFFECEEF5);
  static const Color darkTextSecondary = Color(0xFF9AA3B5);

  /// Color identificativo por categoría de favor (armonizado con la paleta).
  static Color colorCategoria(String categoria) {
    switch (categoria) {
      case 'Hogar':      return const Color(0xFF1C7ED6);
      case 'Transporte': return const Color(0xFFF76707);
      case 'Compras':    return const Color(0xFF2F9E44);
      case 'Tecnología': return const Color(0xFF7048E8);
      case 'Mascotas':   return const Color(0xFFA9744F);
      case 'Mudanza':    return const Color(0xFFE8590C);
      case 'Clases':     return const Color(0xFF0CA678);
      default:           return const Color(0xFF5B6478);
    }
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusPill = 28.0;
  static const double radiusCard = 20.0;
}

/// Sombras suaves y de baja opacidad, tintadas hacia el primary.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF11183A).withValues(alpha: 0.05),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

/// Duraciones estándar de animación.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Estilos puntuales heredados (compatibilidad con pantallas existentes).
/// La fuente la heredan del `TextTheme` global (Inter/Plus Jakarta Sans).
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() => _build(
        brightness: Brightness.light,
        scheme: _lightScheme,
        scaffoldBackground: AppColors.background,
        fieldFill: AppColors.surfaceVariant,
      );

  static ThemeData darkTheme() => _build(
        brightness: Brightness.dark,
        scheme: _darkScheme,
        scaffoldBackground: AppColors.darkBackground,
        fieldFill: AppColors.darkSurfaceVariant,
      );

  // --- ColorSchemes ------------------------------------------------------

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDBE4FF),
    onPrimaryContainer: const Color(0xFF112266),
    secondary: AppColors.accent,
    onSecondary: const Color(0xFF3D2E00),
    secondaryContainer: const Color(0xFFFFF3BF),
    onSecondaryContainer: const Color(0xFF5C4400),
    tertiary: AppColors.positive,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFC3FAE8),
    onTertiaryContainer: const Color(0xFF014737),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: const Color(0xFFFFE3E3),
    onErrorContainer: const Color(0xFF7A0C0C),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFAFBFE),
    surfaceContainer: const Color(0xFFF5F7FB),
    surfaceContainerHigh: const Color(0xFFEDF0F7),
    surfaceContainerHighest: const Color(0xFFE7EBF5),
    outline: AppColors.outline,
    outlineVariant: const Color(0xFFE7EBF5),
    inversePrimary: AppColors.darkPrimary,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.darkPrimary,
    onPrimary: const Color(0xFF0B1437),
    primaryContainer: const Color(0xFF2541A8),
    onPrimaryContainer: const Color(0xFFDBE4FF),
    secondary: const Color(0xFFFFD43B),
    onSecondary: const Color(0xFF3D2E00),
    secondaryContainer: const Color(0xFF5C4400),
    onSecondaryContainer: const Color(0xFFFFE9A8),
    tertiary: const Color(0xFF38D9A9),
    onTertiary: const Color(0xFF00352A),
    tertiaryContainer: const Color(0xFF0B5D49),
    onTertiaryContainer: const Color(0xFFC3FAE8),
    error: const Color(0xFFFF8787),
    onError: const Color(0xFF4D0A0A),
    errorContainer: const Color(0xFF7A1A1A),
    onErrorContainer: const Color(0xFFFFE3E3),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    onSurfaceVariant: AppColors.darkTextSecondary,
    surfaceContainerLowest: const Color(0xFF0E1117),
    surfaceContainerLow: const Color(0xFF141823),
    surfaceContainer: const Color(0xFF161A24),
    surfaceContainerHigh: const Color(0xFF1F2533),
    surfaceContainerHighest: const Color(0xFF262D3D),
    outline: AppColors.darkOutline,
    outlineVariant: const Color(0xFF242A38),
    inversePrimary: AppColors.primary,
  );

  // --- Tipografía --------------------------------------------------------

  static TextTheme _textTheme(ColorScheme s) {
    final body = GoogleFonts.interTextTheme();
    final display = GoogleFonts.plusJakartaSansTextTheme();

    return body.copyWith(
      displayLarge: display.displayLarge
          ?.copyWith(fontWeight: FontWeight.w800, color: s.onSurface, letterSpacing: -1),
      displayMedium: display.displayMedium
          ?.copyWith(fontWeight: FontWeight.w800, color: s.onSurface, letterSpacing: -0.5),
      displaySmall: display.displaySmall
          ?.copyWith(fontWeight: FontWeight.w700, color: s.onSurface),
      headlineLarge: display.headlineLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: s.onSurface, letterSpacing: -0.5),
      headlineMedium: display.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w700, color: s.onSurface),
      headlineSmall: display.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, color: s.onSurface),
      titleLarge: display.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: s.onSurface),
      titleMedium: display.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: s.onSurface),
      titleSmall: display.titleSmall
          ?.copyWith(fontWeight: FontWeight.w600, color: s.onSurface),
      bodyLarge: body.bodyLarge?.copyWith(color: s.onSurface, height: 1.45),
      bodyMedium: body.bodyMedium?.copyWith(color: s.onSurface, height: 1.45),
      bodySmall: body.bodySmall?.copyWith(color: s.onSurfaceVariant, height: 1.4),
      labelLarge: body.labelLarge
          ?.copyWith(fontWeight: FontWeight.w600, color: s.onSurface),
      labelMedium: body.labelMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: s.onSurfaceVariant),
      labelSmall: body.labelSmall
          ?.copyWith(fontWeight: FontWeight.w500, color: s.onSurfaceVariant),
    );
  }

  // --- Constructor de tema -----------------------------------------------

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color fieldFill,
  }) {
    final textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: scheme.outline),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primary.withValues(alpha: 0.14),
        checkmarkColor: scheme.primary,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        elevation: 0,
        height: 68,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        extendedTextStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }
}
