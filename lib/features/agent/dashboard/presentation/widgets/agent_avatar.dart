import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Avatar à initiales avec pastille de présence.
class AgentAvatar extends StatelessWidget {
  final String prenom;
  final String nom;
  final double size;

  const AgentAvatar({
    super.key,
    required this.prenom,
    required this.nom,
    this.size = 48,
  });

  String get _initiales {
    String premiere(String s) => s.trim().isEmpty ? '' : s.trim()[0];
    return '${premiere(prenom)}${premiere(nom)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final pastille = size * 0.28;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.primaryBlueAnthracite,
            child: Text(
              _initiales,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: pastille,
              height: pastille,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
