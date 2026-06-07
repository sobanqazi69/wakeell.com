import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme get _textTheme => GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.15),
              headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2),
              headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
              titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
              bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6),
              bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
              labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
              labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.4),
            ),
      );

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.navyMid,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
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
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
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
          side: const BorderSide(color: AppColors.fieldBorder),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.navy;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.fieldBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      dividerColor: AppColors.divider,
    );
  }

  // Keep dark getter name so existing main.dart reference compiles
  static ThemeData get dark => light;
}
