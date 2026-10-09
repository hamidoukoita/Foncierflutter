import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

enum LotStatus { libre, reserve, vendu, litige }

class StatusBadge extends StatelessWidget {
  final LotStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case LotStatus.libre:
        bgColor = AppColors.successGreen.withOpacity(0.15);
        textColor = AppColors.successGreen;
        label = 'Libre';
        break;
      case LotStatus.reserve:
        bgColor = AppColors.warningAmber.withOpacity(0.15);
        textColor = AppColors.warningAmber;
        label = 'Réservé';
        break;
      case LotStatus.vendu:
        bgColor = AppColors.errorRed.withOpacity(0.15);
        textColor = AppColors.errorRed;
        label = 'Vendu';
        break;
      case LotStatus.litige:
        bgColor = AppColors.black.withOpacity(0.15);
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
