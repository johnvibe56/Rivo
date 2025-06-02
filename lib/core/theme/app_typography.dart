import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font Family
  static const String heeboFont = 'Heebo';

  // Display Styles
  static final TextStyle displayLarge = GoogleFonts.heebo(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: 0.2,
  );

  static final TextStyle displayMedium = GoogleFonts.heebo(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: 0.15,
  );

  // Headline Styles
  static final TextStyle headlineSmall = GoogleFonts.heebo(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: 0.1,
  );

  // Title Styles
  static final TextStyle titleLarge = GoogleFonts.heebo(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static final TextStyle titleMedium = GoogleFonts.heebo(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Styles
  static final TextStyle bodyLarge = GoogleFonts.heebo(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.heebo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static final TextStyle bodySmall = GoogleFonts.heebo(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label Styles
  static final TextStyle labelLarge = GoogleFonts.heebo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final TextStyle labelMedium = GoogleFonts.heebo(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // Button Styles
  static final TextStyle button = GoogleFonts.heebo(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.5,
    letterSpacing: 0.5,
  );
}
