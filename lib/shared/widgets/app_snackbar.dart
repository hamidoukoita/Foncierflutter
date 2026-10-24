import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Messages éphémères homogènes dans toute l'application : bandeau flottant arrondi,
/// pictogramme et couleur selon le sens (vert = action réussie, rouge = erreur).
class AppSnackbar {
  AppSnackbar._();

  static void info(BuildContext context, String message) =>
      infoSur(ScaffoldMessenger.of(context), message);

  static void success(BuildContext context, String message) =>
      successSur(ScaffoldMessenger.of(context), message);

  static void error(BuildContext context, String message) =>
      errorSur(ScaffoldMessenger.of(context), message);

  /// Variantes à utiliser quand l'écran d'origine se ferme juste avant le message
  /// (feuille, boîte de dialogue) : le [ScaffoldMessengerState] est récupéré avant.
  static void infoSur(ScaffoldMessengerState messenger, String message) =>
      _show(messenger, message, AppColors.primaryBlueAnthracite, Icons.info_outline_rounded);

  static void successSur(ScaffoldMessengerState messenger, String message) =>
      _show(messenger, message, AppColors.successGreen, Icons.check_circle_rounded);

  static void errorSur(ScaffoldMessengerState messenger, String message) =>
      _show(messenger, message, AppColors.errorRed, Icons.error_outline_rounded);

  static void _show(ScaffoldMessengerState messenger, String message, Color color, IconData icone) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
          content: Row(
            children: [
              Icon(icone, color: AppColors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
