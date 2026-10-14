import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';

/// Carte choisissable (société, modèle) : bordure ocre et coche lorsqu'elle est sélectionnée.
class CarteSelectionnable extends StatelessWidget {
  final bool selectionnee;
  final bool active;
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CarteSelectionnable({
    super.key,
    required this.selectionnee,
    required this.child,
    this.onTap,
    this.active = true,
    this.padding = const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.55,
      child: Material(
        color: selectionnee ? AppColors.primaryOcreSoft.withValues(alpha: 0.45) : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
          side: BorderSide(
            color: selectionnee ? AppColors.primaryOcre : AppColors.borderLight,
            width: selectionnee ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: active ? onTap : null,
          child: Stack(
            children: [
              Padding(padding: padding, child: child),
              if (selectionnee)
                const Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Icon(Icons.check_circle_rounded, color: AppColors.primaryOcre, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
