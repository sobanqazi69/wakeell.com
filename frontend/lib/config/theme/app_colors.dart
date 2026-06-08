import 'package:flutter/material.dart';

class AppColors {
  // ── Light theme (legacy screens) ──────────────────────────────────────────
  static const Color bg = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9FAFB);
  static const Color navy = Color(0xFF1A1D3A);
  static const Color navyMid = Color(0xFF2C3063);
  static const Color textPrimary = Color(0xFF1A1D3A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color fieldBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF110D2B);
  static const Color cardBg = Color(0xFF1A1040);
  static const Color cardBgAlt = Color(0xFF231757);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color purple = Color(0xFF7B2FBE);
  static const Color gold = Color(0xFFD4A843);
  static const Color darkBorder = Color(0xFF2D2060);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSub = Color(0xFF8B9CC8);
  static const Color darkTextHint = Color(0xFF4A5580);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static BoxShadow cardShadow({double opacity = 0.08, double blur = 20, Offset offset = const Offset(0, 4)}) =>
      BoxShadow(
        color: const Color(0xFF1A1D3A).withValues(alpha: opacity),
        blurRadius: blur,
        offset: offset,
        spreadRadius: 0,
      );

  static BoxShadow darkCardShadow({double opacity = 0.4, double blur = 24, Offset offset = const Offset(0, 6)}) =>
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: opacity),
        blurRadius: blur,
        offset: offset,
        spreadRadius: 0,
      );
}
