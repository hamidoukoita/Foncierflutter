import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Petite pastille à fond pastel (statuts, labels, délais).
class SoftBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const SoftBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
