import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';

/// Fond des écrans d'authentification : halo chaud en haut, crème en bas,
/// avec deux disques décoratifs discrets.
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.warmHeader),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _Disque(taille: 220, couleur: AppColors.primaryOcre.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 120,
            left: -60,
            child: _Disque(taille: 140, couleur: AppColors.brandGreen.withValues(alpha: 0.06)),
          ),
          child,
        ],
      ),
    );
  }
}

class _Disque extends StatelessWidget {
  final double taille;
  final Color couleur;
  const _Disque({required this.taille, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
    );
  }
}
