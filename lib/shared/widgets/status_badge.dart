import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

enum LotStatus { libre, reserve, vendu, litige }

class StatusBadge extends StatelessWidget {
  final LotStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case LotStatus.libre:
        bgColor = AppColors.successGreen.withValues(alpha: 0.15);
        textColor = AppColors.successGreen;
        label = 'Libre';
        break;
      case LotStatus.reserve:
        bgColor = AppColors.warningAmber.withValues(alpha: 0.15);
        textColor = AppColors.warningAmber;
        label = 'Réservé';
        break;
      case LotStatus.vendu:
        bgColor = AppColors.errorRed.withValues(alpha: 0.15);
        textColor = AppColors.errorRed;
        label = 'Vendu';
        break;
      case LotStatus.litige:
        bgColor = AppColors.black.withValues(alpha: 0.15);
        textColor = AppColors.black;
        label = 'Suspendu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.gapXs,
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
