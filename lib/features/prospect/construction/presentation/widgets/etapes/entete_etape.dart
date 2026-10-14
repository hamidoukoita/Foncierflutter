import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Titre et consigne en tête de chaque étape.
class EnteteEtape extends StatelessWidget {
  final String titre;
  final String texte;
  const EnteteEtape({super.key, required this.titre, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.xs),
          Text(texte, style: AppTextStyles.bodyMedium.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}
