import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';

/// Jour du bandeau de dates ; la pastille signale des visites prévues.
class DayChip extends StatelessWidget {
  final DateTime jour;
  final bool selected;
  final bool aDesVisites;
  final VoidCallback onTap;

  const DayChip({
    super.key,
    required this.jour,
    required this.selected,
    required this.aDesVisites,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final texte = selected ? AppColors.white : AppColors.primaryBlueAnthracite;
    final pastille = selected ? AppColors.white : AppColors.primaryOcre;

    return Material(
      color: selected ? AppColors.primaryOcre : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
        side: BorderSide(
          color: selected ? AppColors.primaryOcre : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: InkWell(
        customBorder:
            const RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormatter.jourCourt(jour),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.grey500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${jour.day}',
                style: AppTextStyles.h4.copyWith(color: texte),
              ),
              const SizedBox(height: 2),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: aDesVisites ? pastille : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
