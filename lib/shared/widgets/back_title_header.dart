import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'circle_icon_button.dart';

/// En-tête de page secondaire : bouton retour rond + titre.
class BackTitleHeader extends StatelessWidget {
  final String title;

  const BackTitleHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleIconButton(
          icon: Icons.chevron_left_rounded,
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
