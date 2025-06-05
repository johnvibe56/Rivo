import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart' as app_typography;

class AppTheme {
  // Colors
  static const Color primaryColor = AppColors.primary;
  static const Color accentColor = AppColors.secondary;
  static const Color backgroundColor = AppColors.background;
  static const Color errorColor = AppColors.error;
  static const Color cardColor = AppColors.card;
  static const Color textPrimaryColor = AppColors.textPrimary;
  static const Color shadowColor = AppColors.shadow;
  
  // Border Radius
  static const double borderRadius = 12.0;

  static ThemeData get lightTheme {
    // Create color scheme with surface instead of background
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimaryColor,
      onError: Colors.white,
      brightness: Brightness.light,
    );

    // Build the theme with background color set
    return ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: colorScheme.copyWith(
        surface: backgroundColor,
      ),
      // textDirection is set by the Directionality widget in the widget tree
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.card,
        margin: EdgeInsets.zero,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Text Theme
      textTheme: GoogleFonts.heeboTextTheme(
        TextTheme(
          displayLarge: app_typography.AppTextStyles.displayLarge,
          displayMedium: app_typography.AppTextStyles.displayMedium,
          headlineSmall: app_typography.AppTextStyles.headlineSmall,
          titleLarge: app_typography.AppTextStyles.titleLarge,
          titleMedium: app_typography.AppTextStyles.titleMedium,
          bodyLarge: app_typography.AppTextStyles.bodyLarge,
          bodyMedium: app_typography.AppTextStyles.bodyMedium,
          bodySmall: app_typography.AppTextStyles.bodySmall,
          labelLarge: app_typography.AppTextStyles.labelLarge,
          labelMedium: app_typography.AppTextStyles.labelMedium,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        titleTextStyle: app_typography.AppTextStyles.titleLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: app_typography.AppTextStyles.bodySmall,
        unselectedLabelStyle: app_typography.AppTextStyles.bodySmall,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: true,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: app_typography.AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: app_typography.AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        errorStyle: app_typography.AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
        isDense: true,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: app_typography.AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: app_typography.AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: app_typography.AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Other Theme Customizations
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      cardColor: AppColors.card,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      primaryIconTheme: const IconThemeData(color: AppColors.primary),
      chipTheme: _buildChipTheme(),
      checkboxTheme: _buildCheckboxTheme(),
      snackBarTheme: _buildSnackBarTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.background,
      disabledColor: Colors.grey,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primary,
      padding: EdgeInsets.zero,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  
  static CheckboxThemeData _buildCheckboxTheme() {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            const color = Colors.grey;
            return Color.fromRGBO(
              (color.r * 255.0).round() & 0xff,
              (color.g * 255.0).round() & 0xff,
              (color.b * 255.0).round() & 0xff,
              0.5,
            );
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        },
      ),
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(
        color: AppColors.border,
        width: 1.5,
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            const color = AppColors.primary;
            return Color.fromRGBO(
              (color.r * 255.0).round() & 0xff,
              (color.g * 255.0).round() & 0xff,
              (color.b * 255.0).round() & 0xff,
              0.1,
            );
          }
          return Colors.transparent;
        },
      ),
    );
  }
  
  static SnackBarThemeData _buildSnackBarTheme() {
    return const SnackBarThemeData(
      backgroundColor: AppColors.card,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      elevation: 6,
      behavior: SnackBarBehavior.floating,
    );
  }
}
