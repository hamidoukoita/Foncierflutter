import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';

/// Encart « Construire sur mon terrain » : ouvre le formulaire de soumission d'un projet.
class ConstructionCallout extends StatelessWidget {
  final VoidCallback onTap;

  const ConstructionCallout({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const _Pictogramme(taille: 56),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vous avez un terrain ?', style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xxs),
                Text('Faites construire votre villa sur mesure',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: 170,
                  child: AppActionButton(
                    label: 'Soumettre mon projet',
                    variant: AppActionVariant.soft,
                    height: 34,
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: onTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pictogramme extends StatelessWidget {
  final double taille;
  const _Pictogramme({required this.taille});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: const BoxDecoration(
        color: AppColors.constructionMint,
        borderRadius: AppRadius.radiusLg,
      ),
      child: Icon(Icons.home_work_outlined,
          color: AppColors.constructionGreen, size: taille * 0.5),
    );
  }
}
