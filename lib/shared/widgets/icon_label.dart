import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Ligne « icône + texte » (localisation, téléphone…).
class IconLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final TextStyle? style;

  const IconLabel({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = AppColors.grey700,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style ?? AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
