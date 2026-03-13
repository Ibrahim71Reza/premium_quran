import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      
      // Define the primary colors for the app
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emerald,
        secondary: AppColors.goldAccent,
        surface: AppColors.surface,
      ),

      // Set default Google Fonts for English text
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        bodyMedium: GoogleFonts.outfit(color: AppColors.textSecondary),
      ),

      // FIX: Using CardThemeData for the newest Flutter versions!
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}