import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Configuration typographique de Orient'\Action
///
/// - Titres : Archivo Black (Impact & Aventure)
/// - Corps : Inter (Clarté & Lecture)
class AppTypography {
  AppTypography._();

  // ========================================
  // Titres (Archivo Black)
  // ========================================

  /// H1 - Héro (80px sur desktop, adapté pour mobile)
  static TextStyle get h1 => GoogleFonts.archivoBlack(
    fontSize: 80,
    height: 1.1,
    color: AppColors.charbon,
    letterSpacing: -1.5,
  );

  /// H2 - Sections (48px)
  static TextStyle get h2 => GoogleFonts.archivoBlack(
    fontSize: 48,
    height: 1.2,
    color: AppColors.charbon,
    letterSpacing: -0.5,
  );

  /// H3 - Cartes (24px)
  static TextStyle get h3 => GoogleFonts.archivoBlack(
    fontSize: 24,
    height: 1.3,
    color: AppColors.charbon,
    letterSpacing: 0,
  );

  // ========================================
  // Corps de texte (Inter)
  // ========================================

  /// Paragraphe standard (18px)
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 18,
    height: 1.6,
    color: AppColors.charbon,
    fontWeight: FontWeight.w400,
  );

  /// Texte secondaire (16px)
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    color: AppColors.charbon,
    fontWeight: FontWeight.w400,
  );

  /// Petit texte (14px)
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    height: 1.4,
    color: AppColors.charbon,
    fontWeight: FontWeight.w400,
  );

  // ========================================
  // Labels et Formulaires
  // ========================================

  /// Labels de formulaires (14px Semibold)
  static TextStyle get labelForm => GoogleFonts.inter(
    fontSize: 14,
    height: 1.4,
    color: AppColors.charbon,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// Texte d'input
  static TextStyle get inputText => GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    color: AppColors.charbon,
    fontWeight: FontWeight.w400,
  );

  /// Placeholder d'input
  static TextStyle get inputPlaceholder => GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    color: AppColors.charbon.withValues(alpha: 0.5),
    fontWeight: FontWeight.w400,
  );

  // ========================================
  // Boutons
  // ========================================

  /// Texte de bouton (18px Bold Majuscules)
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 18,
    height: 1.2,
    color: AppColors.bouleau,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.25,
  );

  /// Texte de petit bouton (14px Bold)
  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 14,
    height: 1.2,
    color: AppColors.bouleau,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  // ========================================
  // Utilitaires
  // ========================================

  /// Caption / Métadonnées (12px)
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    height: 1.3,
    color: AppColors.charbon.withValues(alpha: 0.7),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  /// Overline (12px Uppercase)
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 12,
    height: 1.3,
    color: AppColors.charbon.withValues(alpha: 0.7),
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );
}
