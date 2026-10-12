import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Messages éphémères homogènes dans toute l'application.
class AppSnackbar {
  AppSnackbar._();

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.primaryBlueAnthracite);

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.successGreen);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.errorRed);

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        ),
      );
  }
}
