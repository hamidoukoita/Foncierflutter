import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Élévations douces Foncier+ (aucune ombre dure).
class AppShadows {
  AppShadows._();

  /// Cartes et conteneurs posés sur le fond crème.
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.primaryBlueAnthracite.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  /// Cartes de liste : élévation très douce et diffuse.
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.primaryBlueAnthracite.withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  /// Halo chaud sous les boutons d'action principaux.
  static List<BoxShadow> get cta => [
        BoxShadow(
          color: AppColors.primaryOcre.withValues(alpha: 0.32),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  /// Éléments flottants (marqueurs, panneaux sur carte).
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.primaryBlueAnthracite.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
}
