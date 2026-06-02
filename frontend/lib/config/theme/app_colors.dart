import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color darkBg = Color(0xFF130F2D);
  static const Color surfaceContainerLowest = Color(0xFF0E0928);
  static const Color surfaceContainerLow = Color(0xFF1B1736);
  static const Color surfaceContainer = Color(0xFF1F1C3A);
  static const Color surfaceContainerHigh = Color(0xFF2A2645);
  static const Color surfaceContainerHighest = Color(0xFF353150);
  static const Color surfaceBright = Color(0xFF393555);
  static const Color cardBg = Color(0xFF1A1040);

  // Brand
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanDim = Color(0xFF00DAF3);
  static const Color purple = Color(0xFF7B2FBE);
  static const Color gold = Color(0xFFD4A843);

  // Text
  static const Color onSurface = Color(0xFFE5DEFF);
  static const Color onSurfaceVariant = Color(0xFFBAC9CC);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0A9C6);

  // Borders
  static const Color outline = Color(0xFF849396);
  static const Color outlineVariant = Color(0xFF3B494C);
  static const Color fieldBorder = Color(0xFF2D2060);

  // Semantic
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF4D4F);
  static const Color success = Color(0xFF52C41A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purple, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanButtonGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00B8CC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [darkBg, surfaceContainerLow],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxShadow cyanGlow({double opacity = 0.25, double blur = 20}) =>
      BoxShadow(color: cyan.withOpacity(opacity), blurRadius: blur, spreadRadius: 0);
}
