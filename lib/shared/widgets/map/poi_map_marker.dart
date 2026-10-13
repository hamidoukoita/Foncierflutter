import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';

/// Petit marqueur discret pour une commodité.
class PoiMapMarker extends StatelessWidget {
  static const double taille = 32;

  final IconData icone;
  final bool selectionne;

  const PoiMapMarker(
      {super.key, required this.icone, this.selectionne = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: selectionne ? AppColors.primaryBlueAnthracite : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selectionne ? AppColors.white : AppColors.borderLight,
          width: 2,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Icon(
        icone,
        size: 16,
        color: selectionne ? AppColors.white : AppColors.primaryBlueAnthracite,
      ),
    );
  }
}
