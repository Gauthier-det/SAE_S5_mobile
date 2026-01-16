import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Orient'Action typography configuration.
///
/// Defines a complete typographic system using Google Fonts, combining two complementary
/// typefaces to create visual hierarchy and brand identity [web:74][web:76]:
/// - **Headings**: Archivo Black - Bold, impactful typeface for adventure and outdoor themes
/// - **Body Text**: Inter - Clean, highly legible sans-serif for optimal readability
///
/// This configuration follows Material Design typography principles by establishing
/// a type scale with consistent sizing, spacing, and weights [web:80][web:83]. The
/// [GoogleFonts] package provides easy access to over 1,000 open-source fonts from
/// fonts.google.com with automatic caching and bundling [web:74][web:78].
///
/// All text styles are defined as static getters that return configured [TextStyle]
/// objects, allowing consistent typography throughout the application [web:82]. These
/// styles can be used directly or extended with additional properties [web:76][web:81].
///
/// Example usage:
/// ```dart
/// Text(
///   'Welcome to Orient\'Action',
///   style: AppTypography.h1,
/// )
///
/// // Or with custom modifications
/// Text(
///   'Adventure Awaits',
///   style: AppTypography.h2.copyWith(color: Colors.blue),
/// )
/// ```
class AppTypography {
  /// Private constructor to prevent instantiation.
  ///
  /// This class serves as a static configuration container for typography styles,
  /// following Flutter's design pattern for utility classes [web:82].
  AppTypography._();

  // ========================================
  // Headings (Archivo Black)
  // ========================================

  /// H1 - Hero heading style (80px).
  ///
  /// The largest heading size, designed for hero sections and major page titles.
  /// Uses Archivo Black for strong visual impact [web:74][web:81].
  ///
  /// **Properties:**
  /// - Font size: 80px (should be adapted for mobile viewports)
  /// - Line height: 1.1 (tight leading for large display text)
  /// - Letter spacing: -1.5px (optical adjustment for large sizes) [web:79]
  ///
  /// **Recommended usage**: Landing page heroes, splash screens, major section titles
  static TextStyle get h1 => GoogleFonts.archivoBlack(
        fontSize: 80,
        height: 1.1,
        color: AppColors.charbon,
        letterSpacing: -1.5,
      );

  /// H2 - Section heading style (48px).
  ///
  /// Medium-large heading for main content sections and page subdivisions.
  /// Provides strong visual hierarchy below H1 [web:80][web:83].
  ///
  /// **Properties:**
  /// - Font size: 48px
  /// - Line height: 1.2
  /// - Letter spacing: -0.5px [web:79]
  ///
  /// **Recommended usage**: Section headers, card titles, modal headers
  static TextStyle get h2 => GoogleFonts.archivoBlack(
        fontSize: 48,
        height: 1.2,
        color: AppColors.charbon,
        letterSpacing: -0.5,
      );

  /// H3 - Card heading style (24px).
  ///
  /// Smaller heading for component-level titles like cards, list items, and widgets.
  /// Balances impact with space efficiency [web:80][web:83].
  ///
  /// **Properties:**
  /// - Font size: 24px
  /// - Line height: 1.3
  /// - Letter spacing: 0px (normal tracking) [web:79]
  ///
  /// **Recommended usage**: Card headers, list section titles, widget headings
  static TextStyle get h3 => GoogleFonts.archivoBlack(
        fontSize: 24,
        height: 1.3,
        color: AppColors.charbon,
        letterSpacing: 0,
      );

  // ========================================
  // Body Text (Inter)
  // ========================================

  /// Large body text style (18px).
  ///
  /// Standard paragraph text for primary content. Inter font provides excellent
  /// readability at various sizes and weights [web:74][web:78].
  ///
  /// **Properties:**
  /// - Font size: 18px
  /// - Line height: 1.6 (comfortable reading with adequate line spacing) [web:79]
  /// - Font weight: 400 (Regular)
  ///
  /// **Recommended usage**: Main content paragraphs, article body, descriptions
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        height: 1.6,
        color: AppColors.charbon,
        fontWeight: FontWeight.w400,
      );

  /// Medium body text style (16px).
  ///
  /// Secondary content text, slightly smaller than primary body text.
  /// Useful for supporting information and less prominent content [web:80].
  ///
  /// **Properties:**
  /// - Font size: 16px
  /// - Line height: 1.5
  /// - Font weight: 400 (Regular) [web:79]
  ///
  /// **Recommended usage**: Secondary content, captions, supporting text
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        color: AppColors.charbon,
        fontWeight: FontWeight.w400,
      );

  /// Small body text style (14px).
  ///
  /// Smallest body text size for compact content areas and dense information.
  /// Maintains readability while conserving space [web:80][web:83].
  ///
  /// **Properties:**
  /// - Font size: 14px
  /// - Line height: 1.4
  /// - Font weight: 400 (Regular) [web:79]
  ///
  /// **Recommended usage**: Compact lists, table content, footnotes
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        height: 1.4,
        color: AppColors.charbon,
        fontWeight: FontWeight.w400,
      );

  // ========================================
  // Labels and Forms
  // ========================================

  /// Form label text style (14px, Semi-bold).
  ///
  /// Medium-weight text for form field labels, providing clear distinction
  /// from input content while maintaining hierarchy [web:80].
  ///
  /// **Properties:**
  /// - Font size: 14px
  /// - Line height: 1.4
  /// - Font weight: 600 (Semi-bold) [web:79]
  /// - Letter spacing: 0.1px (slight tracking for clarity)
  ///
  /// **Recommended usage**: Input labels, form section headers, field descriptions
  static TextStyle get labelForm => GoogleFonts.inter(
        fontSize: 14,
        height: 1.4,
        color: AppColors.charbon,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  /// Input field text style (16px).
  ///
  /// Text style for user-entered content in form inputs. 16px is the minimum
  /// recommended size to prevent automatic zoom on mobile devices [web:76].
  ///
  /// **Properties:**
  /// - Font size: 16px (prevents mobile zoom) [web:76]
  /// - Line height: 1.5
  /// - Font weight: 400 (Regular) [web:79]
  ///
  /// **Recommended usage**: Text input content, textarea content, editable fields
  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        color: AppColors.charbon,
        fontWeight: FontWeight.w400,
      );

  /// Input placeholder text style (16px, 50% opacity).
  ///
  /// Placeholder hint text with reduced opacity to distinguish it from actual
  /// user input [web:79].
  ///
  /// **Properties:**
  /// - Font size: 16px
  /// - Line height: 1.5
  /// - Font weight: 400 (Regular)
  /// - Opacity: 50% (subtle visual distinction) [web:79]
  ///
  /// **Recommended usage**: Text input placeholders, hint text, empty state labels
  static TextStyle get inputPlaceholder => GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        color: AppColors.charbon.withValues(alpha: 0.5),
        fontWeight: FontWeight.w400,
      );

  // ========================================
  // Buttons
  // ========================================

  /// Primary button text style (18px, Bold, Uppercase).
  ///
  /// Bold, uppercase text for primary call-to-action buttons. Increased letter
  /// spacing improves readability of uppercase text [web:79][web:80].
  ///
  /// **Properties:**
  /// - Font size: 18px
  /// - Line height: 1.2 (tighter for buttons)
  /// - Font weight: 700 (Bold) [web:79]
  /// - Letter spacing: 1.25px (improves uppercase readability) [web:79]
  ///
  /// **Recommended usage**: Primary buttons, CTA buttons, important actions
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 18,
        height: 1.2,
        color: AppColors.bouleau,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.25,
      );

  /// Small button text style (14px, Bold).
  ///
  /// Compact button text for secondary actions and space-constrained interfaces.
  /// Maintains bold weight for button hierarchy [web:79][web:80].
  ///
  /// **Properties:**
  /// - Font size: 14px
  /// - Line height: 1.2
  /// - Font weight: 700 (Bold) [web:79]
  /// - Letter spacing: 1px
  ///
  /// **Recommended usage**: Secondary buttons, icon buttons with text, inline actions
  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 14,
        height: 1.2,
        color: AppColors.bouleau,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      );

  // ========================================
  // Utilities
  // ========================================

  /// Caption text style (12px, 70% opacity).
  ///
  /// Small, subtle text for metadata, timestamps, and supplementary information.
  /// Reduced opacity creates visual hierarchy [web:80][web:83].
  ///
  /// **Properties:**
  /// - Font size: 12px
  /// - Line height: 1.3
  /// - Font weight: 400 (Regular) [web:79]
  /// - Opacity: 70% (subtle visual weight)
  /// - Letter spacing: 0.4px (improves small text legibility) [web:79]
  ///
  /// **Recommended usage**: Timestamps, metadata, image captions, helper text
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        height: 1.3,
        color: AppColors.charbon.withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  /// Overline text style (12px, Uppercase, Semi-bold).
  ///
  /// Small uppercase labels for categories, tags, or section identifiers.
  /// Heavy letter spacing improves uppercase readability at small sizes [web:79][web:80].
  ///
  /// **Properties:**
  /// - Font size: 12px
  /// - Line height: 1.3
  /// - Font weight: 600 (Semi-bold) [web:79]
  /// - Opacity: 70%
  /// - Letter spacing: 1.5px (critical for small uppercase text) [web:79]
  ///
  /// **Recommended usage**: Category labels, tags, eyebrow text, section markers
  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 12,
        height: 1.3,
        color: AppColors.charbon.withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );
}
