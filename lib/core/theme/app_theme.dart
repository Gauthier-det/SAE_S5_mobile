import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Orient'Action application theme configuration.
///
/// Provides a complete Material 3 theme implementation for the Orient'Action app,
/// featuring a nature-inspired color palette and custom typography [web:66][web:58].
/// This configuration centralizes all visual styling to ensure consistency across
/// the application [web:67].
///
/// The theme includes:
/// - **Color Scheme**: Nature/forest-inspired palette using [AppColors]
/// - **Typography**: Custom Google Fonts configuration (Archivo Black + Inter) via [AppTypography]
/// - **Component Themes**: Customized Material components (buttons, inputs, cards, etc.)
///
/// This class follows Flutter's theming best practices by defining all theme properties
/// in a single [ThemeData] object that can be applied to [MaterialApp] [web:58][web:67].
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   title: 'Orient\'Action',
///   theme: AppTheme.lightTheme,
///   home: HomePage(),
/// )
/// ```
class AppTheme {
  /// Private constructor to prevent instantiation.
  ///
  /// This class serves as a static configuration container following
  /// Flutter theming conventions [web:67].
  AppTheme._();

  /// Light theme configuration for the Orient'Action application.
  ///
  /// Returns a fully configured [ThemeData] object with Material 3 enabled,
  /// providing a cohesive visual design system throughout the app [web:66][web:67].
  /// All widget themes inherit from this configuration unless explicitly overridden [web:58].
  static ThemeData get lightTheme {
    return ThemeData(
      // Enable Material 3 design system for modern component styling [web:57][web:69]
      useMaterial3: true,

      // ========================================
      // Color Scheme
      // ========================================
      
      /// Material 3 color scheme defining semantic color roles [web:57][web:69].
      ///
      /// The color scheme uses role-based colors (primary, secondary, tertiary)
      /// instead of hard-coded values, enabling consistent theming across all
      /// Material components [web:57]. Surface containers provide tone-based
      /// backgrounds replacing the old opacity-based elevation system [web:57].
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        // Primary colors - Used for key UI components (FAB, buttons, active states) [web:57]
        primary: AppColors.vertSanglier,
        onPrimary: AppColors.bouleau,
        // Secondary colors - Used for less prominent components [web:57]
        secondary: AppColors.mousseProfonde,
        onSecondary: AppColors.bouleau,
        // Tertiary colors - Used for accent and contrasting elements [web:57]
        tertiary: AppColors.orangeBalise,
        onTertiary: AppColors.bouleau,
        // Error colors - Used for error states and destructive actions [web:57]
        error: AppColors.error,
        onError: AppColors.bouleau,
        // Surface colors - Used for backgrounds and large low-emphasis areas [web:57]
        surface: AppColors.bouleau,
        onSurface: AppColors.charbon,
        // Surface containers - Tone-based surfaces for Material 3 elevation [web:57]
        surfaceContainerHighest: AppColors.galet,
        // Outline color - Used for borders and dividers [web:57]
        outline: AppColors.ecorce,
      ),

      // Default background color for Scaffold widgets
      scaffoldBackgroundColor: AppColors.bouleau,

      // ========================================
      // Typography
      // ========================================
      
      /// Text theme mapping custom typography to Material 3 text roles [web:66][web:67].
      ///
      /// Maps [AppTypography] styles to Material Design text categories,
      /// ensuring consistent typography throughout the app [web:58].
      textTheme: TextTheme(
        // Display styles - Largest text, typically for hero sections
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        // Headline styles - High-emphasis text for section headers
        headlineLarge: AppTypography.h2.copyWith(fontSize: 40),
        headlineMedium: AppTypography.h3.copyWith(fontSize: 20),
        // Body styles - Default text for content and paragraphs
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        // Label styles - Text for buttons, form labels, and captions
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.labelForm,
        labelSmall: AppTypography.caption,
      ),

      // ========================================
      // AppBar Theme
      // ========================================
      
      /// Customized app bar theme for consistent navigation headers [web:66].
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0, // Flat design following Material 3 principles [web:57]
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
      
      /// Elevated button theme for primary call-to-action buttons [web:66][web:67].
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

      /// Outlined button theme for secondary actions [web:66][web:67].
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

      /// Text button theme for tertiary or inline actions [web:66][web:67].
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
      
      /// Input field decoration theme for consistent form styling [web:66][web:67].
      ///
      /// Defines visual styling for text fields and form inputs,
      /// including borders, colors, and spacing [web:58].
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bouleau,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Default border state
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.galet),
        ),
        // Enabled but not focused state
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.galet, width: 1),
        ),
        // Focused state with primary color
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.vertSanglier, width: 2),
        ),
        // Error state when validation fails
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        // Focused error state
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
      
      /// Card theme for container components [web:66][web:67].
      ///
      /// Defines styling for [Card] widgets used throughout the app
      /// for grouping related content [web:58].
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.bouleau,
        surfaceTintColor: Colors.transparent, // Disable Material 3 tint overlay [web:57]
      ),

      // ========================================
      // Divider Theme
      // ========================================
      
      /// Divider theme for visual separators [web:66].
      dividerTheme: const DividerThemeData(
        color: AppColors.galet,
        thickness: 1,
        space: 24, // Vertical space around divider
      ),

      // ========================================
      // Icon Theme
      // ========================================
      
      /// Default icon theme for consistent icon styling [web:66].
      iconTheme: const IconThemeData(color: AppColors.charbon, size: 24),
    );
  }
}
