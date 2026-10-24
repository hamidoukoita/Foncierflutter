import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../../domain/description_maison.dart';

/// Caractéristiques d'une maison en pastilles, suivies des précisions libres.
class DescriptionMaisonChips extends StatelessWidget {
  final DescriptionMaison description;
  const DescriptionMaisonChips({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final caracteristiques = description.caracteristiques;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs + AppSpacing.xxs,
          runSpacing: AppSpacing.xs + AppSpacing.xxs,
          children: [
            for (final c in caracteristiques)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + AppSpacing.xxs, vertical: AppSpacing.xs),
                decoration: const BoxDecoration(color: AppColors.backgroundOffWhite, borderRadius: AppRadius.radiusMd),
                child: Text(c,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        if ((description.precisions ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(description.precisions!, style: AppTextStyles.bodyMedium.copyWith(height: 1.45)),
        ],
      ],
    );
  }
}
