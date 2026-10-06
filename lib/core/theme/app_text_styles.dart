import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Titles (Quicksand)
  static TextStyle get h1 => GoogleFonts.quicksand(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get h2 => GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get h3 => GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlueAnthracite,
      );

  static TextStyle get h4 => GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlueAnthracite,
      );

  // Body Texts (Inter)
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.black,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.grey700,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.grey500,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );
}
