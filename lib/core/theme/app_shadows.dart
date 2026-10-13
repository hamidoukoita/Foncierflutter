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

  /// Éléments flottants (marqueurs, panneaux sur carte).
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.primaryBlueAnthracite.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
}
