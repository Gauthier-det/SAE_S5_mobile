import 'package:flutter/material.dart';

/// Orient'Action color palette.
///
/// A custom color scheme inspired by nature and forest orienteering, designed to
/// provide a cohesive and thematic visual identity for the Orient'Action application.
/// This class defines immutable color constants following Flutter's [Color] class pattern [web:56][web:63].
///
/// The palette is organized into three categories:
/// - **Primary Colors**: Brand identity colors for main UI elements
/// - **Neutral Colors**: Background, text, and structural colors
/// - **State Colors**: Semantic colors for feedback and status communication
///
/// All colors use the ARGB format (0xAARRGGBB) where AA is alpha/opacity,
/// RR is red, GG is green, and BB is blue [web:63]. This follows Material Design's
/// color system conventions [web:57][web:62].
///
/// Example usage:
/// ```dart
/// Container(
///   color: AppColors.vertSanglier,
///   child: Text(
///     'Welcome',
///     style: TextStyle(color: AppColors.bouleau),
///   ),
/// )
/// ```
class AppColors {
  /// Private constructor to prevent instantiation.
  ///
  /// This class is designed as a static constant container following
  /// Flutter's [Colors] class pattern [web:56].
  AppColors._();

  // ========================================
  // Primary Colors
  // ========================================

  /// Vert Sanglier (Wild Boar Green) - Primary brand color.
  ///
  /// A deep, forest green representing the wilderness and outdoor adventure.
  /// Use this color for primary actions, app bars, and key brand elements.
  /// Hex: #1B3022 | RGB(27, 48, 34)
  static const Color vertSanglier = Color(0xFF1B3022);

  /// Mousse Profonde (Deep Moss) - Secondary brand color.
  ///
  /// A rich moss green that complements the primary color, evoking forest floor
  /// and natural growth. Use for secondary actions and success states.
  /// Hex: #2D5A27 | RGB(45, 90, 39)
  static const Color mousseProfonde = Color(0xFF2D5A27);

  /// Orange Balise (Beacon Orange) - Accent color for calls-to-action.
  ///
  /// A vibrant orange reminiscent of orienteering markers and trail blazes.
  /// Use for primary buttons, important CTAs, and elements requiring attention [web:58].
  /// Hex: #FF6B00 | RGB(255, 107, 0)
  static const Color orangeBalise = Color(0xFFFF6B00);

  // ========================================
  // Neutral Colors
  // ========================================

  /// Bouleau (Birch) - Primary background color.
  ///
  /// A warm off-white inspired by birch bark, providing a soft, natural canvas
  /// for content. Use as the main page background color [web:58].
  /// Hex: #FDFCF8 | RGB(253, 252, 248)
  static const Color bouleau = Color(0xFFFDFCF8);

  /// Charbon (Charcoal) - Primary text color.
  ///
  /// A dark, near-black color for maximum readability on light backgrounds.
  /// Use for body text, headings, and primary content [web:58].
  /// Hex: #212529 | RGB(33, 37, 41)
  static const Color charbon = Color(0xFF212529);

  /// Galet (Pebble) - Input fields and light gray surfaces.
  ///
  /// A soft, light gray reminiscent of smooth river stones. Use for form inputs,
  /// disabled states, and subtle background differentiation.
  /// Hex: #E9ECEF | RGB(233, 236, 239)
  static const Color galet = Color(0xFFE9ECEF);

  /// Écorce (Bark) - Borders and footer elements.
  ///
  /// A warm brown inspired by tree bark, providing natural contrast and
  /// grounding for page elements. Use for borders, dividers, and footer sections.
  /// Hex: #7A5C43 | RGB(122, 92, 67)
  static const Color ecorce = Color(0xFF7A5C43);

  // ========================================
  // State Colors
  // ========================================

  /// Success state color.
  ///
  /// Uses [mousseProfonde] to maintain brand consistency while communicating
  /// positive actions and successful operations [web:57].
  static const Color success = mousseProfonde;

  /// Error state color.
  ///
  /// A standard red for error messages, validation failures, and destructive actions.
  /// Provides clear visual feedback for problems requiring user attention [web:57].
  /// Hex: #DC3545 | RGB(220, 53, 69)
  static const Color error = Color(0xFFDC3545);

  /// Warning state color.
  ///
  /// Uses [orangeBalise] to maintain brand identity while signaling caution
  /// or important information requiring user awareness [web:57].
  static const Color warning = orangeBalise;

  /// Info state color.
  ///
  /// A bright cyan for informational messages and neutral notifications that
  /// don't require immediate action [web:57].
  /// Hex: #0DCAF0 | RGB(13, 202, 240)
  static const Color info = Color(0xFF0DCAF0);
}
