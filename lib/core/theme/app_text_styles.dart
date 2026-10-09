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

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );
}
