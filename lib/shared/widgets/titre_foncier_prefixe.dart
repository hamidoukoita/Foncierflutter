import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/titre_foncier.dart';

/// Préfixe « TF- » affiché en tête des champs de numéro de Titre Foncier : l'utilisateur ne tape que la référence.
class TitreFoncierPrefixe extends StatelessWidget {
  const TitreFoncierPrefixe({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSpacing.gapSm,
        const Icon(Icons.verified_outlined, size: 20),
        AppSpacing.gapSm,
        Text(
          TitreFoncier.prefixe,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primaryBlueAnthracite,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
      ],
    );
  }
}
