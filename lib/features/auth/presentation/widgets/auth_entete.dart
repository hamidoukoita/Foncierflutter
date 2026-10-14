import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/foncier_logo.dart';

/// En-tête des écrans d'authentification : logo officiel, titre et sous-titre centrés.
class AuthEntete extends StatelessWidget {
  final String titre;
  final String sousTitre;
  final double hauteurLogo;

  const AuthEntete(
      {super.key,
      required this.titre,
      required this.sousTitre,
      this.hauteurLogo = 96});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FoncierLogo(hauteur: hauteurLogo),
        const SizedBox(height: AppSpacing.md),
        Text(titre,
            textAlign: TextAlign.center, style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(sousTitre,
            textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
