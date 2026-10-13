import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum AppActionVariant {
  /// Fond anthracite, texte blanc (action principale d'une carte).
  dark,

  /// Fond crème bordé, texte anthracite (action secondaire).
  outlined,

  /// Fond ocre, texte blanc (appel à l'action fort).
  accent,

  /// Anthracite clair, pour une action secondaire posée sur fond sombre.
  darkSubtle,

  /// Rouge, pour une action irréversible ou de sortie (déconnexion…).
  danger,
}

/// Bouton compact avec icône optionnelle, utilisé dans les cartes.
class AppActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final AppActionVariant variant;
  final double height;

  const AppActionButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = AppActionVariant.outlined,
    this.height = 40,
  });

  Color get _background => switch (variant) {
        AppActionVariant.dark => AppColors.primaryBlueAnthracite,
        AppActionVariant.outlined => AppColors.backgroundOffWhite,
        AppActionVariant.accent => AppColors.primaryOcre,
        AppActionVariant.darkSubtle => AppColors.primaryBlueSoft,
        AppActionVariant.danger => AppColors.errorRed,
      };

  Color get _foreground => variant == AppActionVariant.outlined
      ? AppColors.primaryBlueAnthracite
      : AppColors.white;

  BorderSide get _border => variant == AppActionVariant.outlined
      ? const BorderSide(color: AppColors.borderLight, width: 1.5)
      : BorderSide.none;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _background,
          foregroundColor: _foreground,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusLg,
            side: _border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: _foreground),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(trailingIcon, size: 16, color: _foreground),
            ],
          ],
        ),
      ),
    );
  }
}
