import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Bouton rond blanc bordé (retour, calendrier, notifications…).
/// [showDot] affiche une pastille ocre (ex. notification non lue).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool showDot;
  final double size;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.showDot = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.white,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.borderLight, width: 1.5),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Center(
                child: Icon(
                  icon,
                  size: size * 0.45,
                  color: AppColors.primaryBlueAnthracite,
                ),
              ),
            ),
          ),
          if (showDot)
            Positioned(
              top: size * 0.08,
              right: size * 0.08,
              child: Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.primaryOcre,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
