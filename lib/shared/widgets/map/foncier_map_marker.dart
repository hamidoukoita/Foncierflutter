import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';

/// Marqueur principal Foncier+ (pastille ocre + pointe) pour le bien.
class FoncierMapMarker extends StatelessWidget {
  static const double largeur = 46;
  static const double hauteur = 56;

  final IconData icone;

  const FoncierMapMarker({super.key, this.icone = Icons.home_work_rounded});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largeur,
      height: hauteur,
      child: Column(
        children: [
          Container(
            width: largeur,
            height: largeur,
            decoration: BoxDecoration(
              color: AppColors.primaryOcre,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
              boxShadow: AppShadows.floating,
            ),
            child: Icon(icone, color: AppColors.white, size: 22),
          ),
          ClipPath(
            clipper: _PointeClipper(),
            child: Container(
              width: 14,
              height: hauteur - largeur,
              color: AppColors.primaryOcre,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
