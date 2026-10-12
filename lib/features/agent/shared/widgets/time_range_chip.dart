import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Plage horaire en police monospace (« 10:30 - 11:30 »).
/// [highlighted] = fond ambré pour la prochaine visite.
class TimeRangeChip extends StatelessWidget {
  final String label;
  final bool highlighted;

  const TimeRangeChip({
    super.key,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.ambreSoft : AppColors.grey100,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTextStyles.mono.copyWith(
          fontSize: 12,
          color: highlighted
              ? AppColors.ambreReservation24h
              : AppColors.primaryBlueAnthracite,
        ),
      ),
    );
  }
}
