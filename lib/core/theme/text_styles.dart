import 'package:flutter/material.dart';

/// Tailwind taslaklarındaki `fontSize` token'larının Flutter karşılığı.
abstract class AppTextStyles {
  static const displayLg = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: -0.02,
    fontWeight: FontWeight.w700,
  );

  static const headlineMd = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
  );

  static const headlineMdMobile = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );

  static const headlineSm = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );

  static const titleLg = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static const bodyMd = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const bodySm = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const labelMd = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.05,
    fontWeight: FontWeight.w600,
  );

  static const labelSm = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
  );
}
