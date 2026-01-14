import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Application theme configuration
///
/// Configuration complète du thème Orient'\Action avec :
/// - Palette de couleurs nature/forêt
/// - Typographies Google Fonts (Archivo Black + Inter)
/// - Composants UI personnalisés
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // ========================================
      // Color Scheme
      // ========================================
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.vertSanglier,
        onPrimary: AppColors.bouleau,
        secondary: AppColors.mousseProfonde,
        onSecondary: AppColors.bouleau,
        tertiary: AppColors.orangeBalise,
        onTertiary: AppColors.bouleau,
        error: AppColors.error,
        onError: AppColors.bouleau,
        surface: AppColors.bouleau,
        onSurface: AppColors.charbon,
        surfaceContainerHighest: AppColors.galet,
        outline: AppColors.ecorce,
      ),

      scaffoldBackgroundColor: AppColors.bouleau,

      // ========================================
      // Typography
      // ========================================
      textTheme: TextTheme(
        // Titres (Display)
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        // Titres (Headlines) - distinct sizes for flexibility
        headlineLarge: AppTypography.h2.copyWith(fontSize: 40),
        headlineMedium: AppTypography.h3.copyWith(fontSize: 20),
        // Corps de texte
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        // Labels
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.labelForm,
        labelSmall: AppTypography.caption,
      ),

      // ========================================
      // AppBar Theme
      // ========================================
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.vertSanglier,
        foregroundColor: AppColors.bouleau,
        titleTextStyle: AppTypography.h3.copyWith(
          color: AppColors.bouleau,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: AppColors.bouleau),
      ),

      // ========================================
      // Button Themes
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vertSanglier,
          foregroundColor: AppColors.bouleau,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vertSanglier,
          textStyle: AppTypography.button.copyWith(
            color: AppColors.vertSanglier,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: const BorderSide(color: AppColors.vertSanglier, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vertSanglier,
          textStyle: AppTypography.buttonSmall,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // ========================================
      // Input Decoration Theme
      // ========================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bouleau,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.galet),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.galet, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.vertSanglier, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.labelForm,
        hintStyle: AppTypography.inputPlaceholder,
      ),

      // ========================================
      // Card Theme
      // ========================================
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.bouleau,
        surfaceTintColor: Colors.transparent,
      ),

      // ========================================
      // Divider Theme
      // ========================================
      dividerTheme: const DividerThemeData(
        color: AppColors.galet,
        thickness: 1,
        space: 24,
      ),

      // ========================================
      // Icon Theme
      // ========================================
      iconTheme: const IconThemeData(color: AppColors.charbon, size: 24),
    );
  }
}
