import 'package:flutter/material.dart';

/// Uygulamanın tüm renk sabitlerini barındırır.
/// HTML taslağındaki Tailwind renk sistemiyle birebir eşleşir.
abstract class AppColors {
  // ── PRIMARY ──────────────────────────────────────────────────────────────
  static const primary = Color(0xFF0061A7);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0096FF);
  static const onPrimaryContainer = Color(0xFF002D52);
  static const primaryFixed = Color(0xFFD2E4FF);
  static const primaryFixedDim = Color(0xFFA1C9FF);
  static const onPrimaryFixed = Color(0xFF001C37);
  static const onPrimaryFixedVariant = Color(0xFF00487F);
  static const inversePrimary = Color(0xFFA1C9FF);

  // ── SECONDARY ─────────────────────────────────────────────────────────────
  static const secondary = Color(0xFF5D5F5F);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFDFE0E0);
  static const onSecondaryContainer = Color(0xFF616363);
  static const secondaryFixed = Color(0xFFE2E2E2);
  static const secondaryFixedDim = Color(0xFFC6C6C7);
  static const onSecondaryFixed = Color(0xFF1A1C1C);
  static const onSecondaryFixedVariant = Color(0xFF454747);

  // ── TERTIARY ──────────────────────────────────────────────────────────────
  static const tertiary = Color(0xFF964900);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFE57300);
  static const onTertiaryContainer = Color(0xFF492000);
  static const tertiaryFixed = Color(0xFFFFDCC6);
  static const tertiaryFixedDim = Color(0xFFFFB786);
  static const onTertiaryFixed = Color(0xFF311300);
  static const onTertiaryFixedVariant = Color(0xFF723600);

  // ── ERROR ─────────────────────────────────────────────────────────────────
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // ── SURFACE ───────────────────────────────────────────────────────────────
  static const surface = Color(0xFFF8F9FF);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const surfaceDim = Color(0xFFD7DAE3);
  static const onSurface = Color(0xFF171C22);
  static const surfaceVariant = Color(0xFFDFE2EB);
  static const onSurfaceVariant = Color(0xFF3F4753);
  static const surfaceTint = Color(0xFF0061A7);
  static const inverseSurface = Color(0xFF2C3137);
  static const inverseOnSurface = Color(0xFFEDF1FA);

  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF0F3FD);
  static const surfaceContainer = Color(0xFFEBEEF7);
  static const surfaceContainerHigh = Color(0xFFE5E8F1);
  static const surfaceContainerHighest = Color(0xFFDFE2EB);

  // ── BACKGROUND ────────────────────────────────────────────────────────────
  static const background = Color(0xFFF8F9FF);
  static const onBackground = Color(0xFF171C22);

  // ── OUTLINE ───────────────────────────────────────────────────────────────
  static const outline = Color(0xFF707884);
  static const outlineVariant = Color(0xFFBFC7D5);

  // ── DARK THEME ────────────────────────────────────────────────────────────
  static const surfaceDark = Color(0xFF0F1318);
  static const surfaceContainerDark = Color(0xFF1B2027);
  static const surfaceContainerLowDark = Color(0xFF171C22);
  static const surfaceContainerLowestDark = Color(0xFF0A0F14);
  static const surfaceContainerHighDark = Color(0xFF252B32);
  static const surfaceContainerHighestDark = Color(0xFF2F353D);
  static const onSurfaceDark = Color(0xFFDFE2EB);
  static const onSurfaceVariantDark = Color(0xFFBFC7D5);
  static const outlineDark = Color(0xFF8A929E);
  static const outlineVariantDark = Color(0xFF3F4753);
}