import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Bouton d'action pleine largeur.
/// - principal : dégradé ocre + halo chaud ;
/// - [isSecondary] : fond blanc bordé, texte anthracite.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.height = AppSizes.buttonLarge,
  });

  bool get _actif => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final couleurTexte =
        isSecondary ? AppColors.primaryBlueAnthracite : AppColors.white;

    final contenu = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(color: couleurTexte, strokeWidth: 2.5),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: couleurTexte),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.buttonLarge.copyWith(color: couleurTexte),
                ),
              ),
            ],
          );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: onPressed == null && !isLoading ? 0.55 : 1,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: isSecondary ? null : AppGradients.cta,
          color: isSecondary ? AppColors.white : null,
          borderRadius: AppRadius.button,
          border: isSecondary
              ? Border.all(color: AppColors.borderLight, width: 1.5)
              : null,
          boxShadow: isSecondary || !_actif ? null : AppShadows.cta,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.button,
            onTap: _actif ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(child: contenu),
            ),
          ),
        ),
      ),
    );
  }
}
