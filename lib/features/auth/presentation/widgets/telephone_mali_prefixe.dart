import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Indicatif du Mali affiché en tête des champs de numéro de téléphone.
class TelephoneMaliPrefixe extends StatelessWidget {
  const TelephoneMaliPrefixe({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSpacing.gapSm,
        const Text('🇲🇱', style: TextStyle(fontSize: 15)),
        AppSpacing.gapSm,
        Text(
          '+223',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryBlueAnthracite,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          height: 20,
          width: 1,
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + AppSpacing.xxs),
          color: AppColors.borderLight,
        ),
      ],
    );
  }
}
