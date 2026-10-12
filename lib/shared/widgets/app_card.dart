import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Carte blanche arrondie standard Foncier+.
/// [highlighted] l'entoure en ocre pour signaler l'élément prioritaire.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
        side: BorderSide(
          color: highlighted ? AppColors.primaryOcre : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
