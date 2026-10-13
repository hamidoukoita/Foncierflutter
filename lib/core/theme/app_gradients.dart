import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Dégradés de la charte Foncier+.
class AppGradients {
  AppGradients._();

  /// Bouton d'action principal : ocre chaud.
  static const LinearGradient cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryOcreLight, AppColors.primaryOcre, AppColors.primaryOcreDark],
    stops: [0, 0.55, 1],
  );

  /// Cartes mises en avant sur fond anthracite.
  static const LinearGradient navy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryBlueSoft, AppColors.primaryBlueAnthracite],
  );

  /// Halo chaud en tête d'écran.
  static const LinearGradient warmHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryOcreSoft, AppColors.backgroundOffWhite],
  );
}
