import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBg = Color(0xFF110D2B);
  static const Color cardBg = Color(0xFF1A1040);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color purple = Color(0xFF7B2FBE);
  static const Color gold = Color(0xFFD4A843);
  static const Color fieldBorder = Color(0xFF2D2060);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF8A8A9A);
  static const Color error = Color(0xFFFF4D4F);
  static const Color success = Color(0xFF52C41A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purple, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [darkBg, Color(0xFF1A1040)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
