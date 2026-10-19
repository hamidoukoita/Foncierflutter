import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Bulle rouge posée sur une icône : nombre d'éléments qui attendent l'utilisateur.
/// Rien n'est affiché à zéro ; au-delà de 9, « 9+ ».
class PastilleCompteur extends StatelessWidget {
  final int nombre;
  final Widget child;

  const PastilleCompteur(
      {super.key, required this.nombre, required this.child});

  @override
  Widget build(BuildContext context) {
    if (nombre <= 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -6,
          right: -10,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.errorRed,
              borderRadius: AppRadius.radiusRound,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: Text(
              nombre > 9 ? '9+' : '$nombre',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                height: 1.1,
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
