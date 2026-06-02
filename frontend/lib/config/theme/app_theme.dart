import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme get _textTheme => GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.02 * 48, height: 56 / 48),
              headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 40 / 32),
              headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 32 / 24),
              titleMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 28 / 20),
              bodyLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, height: 28 / 18),
              bodyMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
              labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.01 * 14, height: 20 / 14),
              labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05 * 12, height: 16 / 12),
            ),
      );

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        onPrimary: Color(0xFF00363D),
        secondary: AppColors.purple,
        surface: AppColors.surfaceContainer,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.outfit(color: AppColors.onSurfaceVariant, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: AppColors.onSurfaceVariant, fontSize: 14),
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIconColor: AppColors.onSurfaceVariant,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: const Color(0xFF00363D),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: AppColors.outlineVariant),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.cyan;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF00363D)),
        side: const BorderSide(color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
