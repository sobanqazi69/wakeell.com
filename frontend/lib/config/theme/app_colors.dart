import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9FAFB);

  // Brand
  static const Color navy = Color(0xFF1A1D3A);
  static const Color navyMid = Color(0xFF2C3063);

  // Text
  static const Color textPrimary = Color(0xFF1A1D3A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Borders
  static const Color fieldBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static BoxShadow cardShadow({double opacity = 0.08, double blur = 20, Offset offset = const Offset(0, 4)}) =>
      BoxShadow(
        color: const Color(0xFF1A1D3A).withValues(alpha: opacity),
        blurRadius: blur,
        offset: offset,
        spreadRadius: 0,
      );
}
