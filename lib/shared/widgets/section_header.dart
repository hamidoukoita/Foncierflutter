import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Titre de section avec action optionnelle à droite (ex. « Voir tout (2) › »).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.h4)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              '$actionLabel ›',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryOcre,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
