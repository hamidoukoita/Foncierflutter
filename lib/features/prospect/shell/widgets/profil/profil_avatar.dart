import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';

/// Avatar à initiales de l'acquéreur, cerclé d'un anneau ocre.
class ProfilAvatar extends StatelessWidget {
  final AuthUser? user;
  final double taille;

  const ProfilAvatar({super.key, required this.user, this.taille = 44});

  static String initiales(AuthUser? user) {
    String premiere(String? s) =>
        (s == null || s.trim().isEmpty) ? '' : s.trim()[0];
    final valeur =
        '${premiere(user?.prenom)}${premiere(user?.nom)}'.toUpperCase();
    return valeur.isEmpty ? 'A' : valeur;
  }

  @override
  Widget build(BuildContext context) {
    final anneau = taille > 60 ? 3.0 : 2.0;
    return Container(
      width: taille,
      height: taille,
      padding: EdgeInsets.all(anneau),
      decoration: const BoxDecoration(
          gradient: AppGradients.cta, shape: BoxShape.circle),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryBlueAnthracite,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: anneau),
        ),
        child: Text(
          initiales(user),
          style: AppTextStyles.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: taille * 0.3,
          ),
        ),
      ),
    );
  }
}
