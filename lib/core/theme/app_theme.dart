import 'package:flutter/material.dart';
import 'package:sales_ledger/core/constants/color_constants.dart';

abstract class AppTheme {
  // ── LIGHT THEME ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          // Primary
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          // Secondary
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          // Tertiary
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          // Error
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          // Surface
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          // Outline
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          // Inverse
          inverseSurface: AppColors.inverseSurface,
          onInverseSurface: AppColors.inverseOnSurface,
          inversePrimary: AppColors.inversePrimary,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            side: const BorderSide(color: AppColors.primary, width: 2),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  // ── DARK THEME ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primaryFixedDim,
          onPrimary: AppColors.onPrimaryFixed,
          primaryContainer: AppColors.primary,
          onPrimaryContainer: AppColors.primaryFixed,
          secondary: AppColors.secondaryFixedDim,
          onSecondary: AppColors.onSecondaryFixed,
          secondaryContainer: AppColors.secondary,
          onSecondaryContainer: AppColors.secondaryFixed,
          tertiary: AppColors.tertiaryFixedDim,
          onTertiary: AppColors.onTertiaryFixed,
          tertiaryContainer: AppColors.tertiary,
          onTertiaryContainer: AppColors.tertiaryFixed,
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: AppColors.surfaceDark,
          onSurface: AppColors.onSurfaceDark,
          surfaceContainerLowest: AppColors.surfaceContainerLowestDark,
          surfaceContainerLow: AppColors.surfaceContainerLowDark,
          surfaceContainer: AppColors.surfaceContainerDark,
          surfaceContainerHigh: AppColors.surfaceContainerHighDark,
          surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
          onSurfaceVariant: AppColors.onSurfaceVariantDark,
          outline: AppColors.outlineDark,
          outlineVariant: AppColors.outlineVariantDark,
          inverseSurface: AppColors.onSurfaceDark,
          onInverseSurface: AppColors.surfaceDark,
          inversePrimary: AppColors.primary,
        ),
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceContainerLowDark,
          foregroundColor: AppColors.onSurfaceDark,
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outlineVariantDark),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLowDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.outlineVariantDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.outlineVariantDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryFixedDim, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFFFB4AB), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}