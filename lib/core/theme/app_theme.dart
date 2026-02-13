import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Application theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.actionBlue,
        primaryContainer: AppColors.actionBlueLight,
        secondary: AppColors.deepNavy,
        secondaryContainer: AppColors.deepNavyLight,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnDark,
        onSecondary: AppColors.textOnDark,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnDark,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.neutralGrey,

      // Typography - Inter Font
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeXxl,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeXl,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBase,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBase,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeSm,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBase,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeLg,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.background,
        elevation: 1,
        shadowColor: Color(0x1A1B263B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionBlue,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd,
            vertical: AppConstants.spaceSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.actionBlue,
          textStyle: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBase,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBase,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBase,
          color: AppColors.textDisabled,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
