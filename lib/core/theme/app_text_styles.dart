import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typographie officielle Foncier+ : Quicksand pour les titres, Inter pour le corps.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get h1 => GoogleFonts.quicksand(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get h2 => GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get h3 => GoogleFonts.quicksand(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get h4 => GoogleFonts.quicksand(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get homeGreeting => GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get sectionTitle => GoogleFonts.quicksand(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get heroTitle => GoogleFonts.quicksand(
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      );

  /// Titre d'écran principal (onglets, pages).
  static TextStyle get pageTitle => GoogleFonts.quicksand(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: AppColors.primaryBlueAnthracite,
      );

  /// Titre de carte (annonce, visite, réservation).
  static TextStyle get cardTitle => GoogleFonts.quicksand(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlueAnthracite,
      );

  /// Petit libellé en capitales (sur-titres, catégories).
  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      );

  /// Libellé de champ / métadonnée appuyée.
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlueAnthracite,
      );

  /// Texte des boutons principaux.
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: AppColors.white,
      );

  static TextStyle get price => GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.grey700,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  // Horaires / références techniques (monospace)
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );
}
