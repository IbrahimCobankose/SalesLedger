import 'package:flutter/material.dart';
import 'package:sales_ledger/core/constants/color_constants.dart';
import 'package:sales_ledger/core/theme/text_styles.dart';

/// Uygulamanın aydınlık ve karanlık [ThemeData] tanımları.
/// Renkler [AppColors], tipografi [AppTextStyles] kaynağından gelir.
abstract class AppTheme {
  static ThemeData get light => _build(_lightScheme);

  static ThemeData get dark => _build(_darkScheme);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    surfaceTint: AppColors.surfaceTint,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    inversePrimary: AppColors.inversePrimary,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryFixedDim,
    onPrimary: AppColors.onPrimaryFixed,
    primaryContainer: AppColors.onPrimaryFixedVariant,
    onPrimaryContainer: AppColors.primaryFixed,
    secondary: AppColors.secondaryFixedDim,
    onSecondary: AppColors.onSecondaryFixed,
    secondaryContainer: AppColors.onSecondaryFixedVariant,
    onSecondaryContainer: AppColors.secondaryFixed,
    tertiary: AppColors.tertiaryFixedDim,
    onTertiary: AppColors.onTertiaryFixed,
    tertiaryContainer: AppColors.onTertiaryFixedVariant,
    onTertiaryContainer: AppColors.tertiaryFixed,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerLowest: AppColors.surfaceContainerLowestDark,
    surfaceContainerLow: AppColors.surfaceContainerLowDark,
    surfaceContainer: AppColors.surfaceContainerDark,
    surfaceContainerHigh: AppColors.surfaceContainerHighDark,
    surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
    surfaceTint: AppColors.primaryFixedDim,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.outlineVariantDark,
    inverseSurface: AppColors.onSurface,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.primary,
  );

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLg.copyWith(color: scheme.onSurface),
        headlineMedium: AppTextStyles.headlineMd.copyWith(color: scheme.onSurface),
        headlineSmall: AppTextStyles.headlineSm.copyWith(color: scheme.onSurface),
        titleLarge: AppTextStyles.titleLg.copyWith(color: scheme.onSurface),
        bodyMedium: AppTextStyles.bodyMd.copyWith(color: scheme.onSurface),
        bodySmall: AppTextStyles.bodySm.copyWith(color: scheme.onSurfaceVariant),
        labelMedium: AppTextStyles.labelMd.copyWith(color: scheme.onSurface),
        labelSmall: AppTextStyles.labelSm.copyWith(color: scheme.onSurfaceVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: AppTextStyles.labelMd.copyWith(color: scheme.onSurface),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: scheme.outline),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.titleLg,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.titleLg,
        ),
      ),
    );
  }
}
