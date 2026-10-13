import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';

/// En-tête flottant au-dessus de la carte : retour + nom du bien.
class MapTopBar extends StatelessWidget {
  final String titre;
  final String? sousTitre;

  const MapTopBar({super.key, required this.titre, this.sousTitre});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              shape: BoxShape.circle, boxShadow: AppShadows.floating),
          child: CircleIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () => context.pop(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.radiusXl,
              boxShadow: AppShadows.floating,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4),
                if (sousTitre != null)
                  Text(
                    sousTitre!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
