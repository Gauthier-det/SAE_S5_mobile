import 'package:flutter/material.dart';

/// Palette de couleurs Orient'\Action
///
/// Inspirée par la nature et l'orientation forestière
class AppColors {
  AppColors._();

  // ========================================
  // Couleurs Primaires
  // ========================================

  /// Vert Sanglier - Couleur primaire de l'application
  static const Color vertSanglier = Color(0xFF1B3022);

  /// Mousse Profonde - Couleur secondaire
  static const Color mousseProfonde = Color(0xFF2D5A27);

  /// Orange Balise - Couleur d'accent pour les CTA
  static const Color orangeBalise = Color(0xFFFF6B00);

  // ========================================
  // Couleurs Neutres
  // ========================================

  /// Bouleau - Fond de page principal
  static const Color bouleau = Color(0xFFFDFCF8);

  /// Charbon - Texte principal
  static const Color charbon = Color(0xFF212529);

  /// Galet - Inputs et gris clair
  static const Color galet = Color(0xFFE9ECEF);

  /// Écorce - Bordures et pied de page
  static const Color ecorce = Color(0xFF7A5C43);

  // ========================================
  // Couleurs d'État
  // ========================================

  /// Succès (basé sur mousse profonde)
  static const Color success = mousseProfonde;

  /// Erreur
  static const Color error = Color(0xFFDC3545);

  /// Avertissement (basé sur orange balise)
  static const Color warning = orangeBalise;

  /// Info
  static const Color info = Color(0xFF0DCAF0);
}
