import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum AppActionVariant {
  /// Fond anthracite, texte blanc (action principale d'une carte).
  dark,

  /// Fond blanc bordé, texte anthracite (action secondaire).
  outlined,

  /// Dégradé ocre, texte blanc (appel à l'action fort).
  accent,

  /// Anthracite clair, pour une action secondaire posée sur fond sombre.
  darkSubtle,

  /// Rouge, pour une action irréversible ou de sortie (déconnexion…).
  danger,

  /// Teinte ocre douce, texte ocre (action tertiaire).
  soft,
}

/// Bouton compact avec icône optionnelle, utilisé dans les cartes et dialogues.
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
    this.height = AppSizes.buttonSmall,
  });

  Color? get _fond => switch (variant) {
        AppActionVariant.dark => AppColors.primaryBlueAnthracite,
        AppActionVariant.outlined => AppColors.white,
        AppActionVariant.accent => null,
        AppActionVariant.darkSubtle => AppColors.primaryBlueSoft,
        AppActionVariant.danger => AppColors.errorRed,
        AppActionVariant.soft => AppColors.primaryOcreSoft,
      };

  Color get _texte => switch (variant) {
        AppActionVariant.outlined => AppColors.primaryBlueAnthracite,
        AppActionVariant.soft => AppColors.primaryOcreDark,
        _ => AppColors.white,
      };

  @override
  Widget build(BuildContext context) {
    final texte = _texte;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: _fond,
          gradient: variant == AppActionVariant.accent ? AppGradients.cta : null,
          borderRadius: AppRadius.radiusMd,
          border: variant == AppActionVariant.outlined
              ? Border.all(color: AppColors.borderLight, width: 1.5)
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.radiusMd,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 17, color: texte),
                    const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(color: texte, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(trailingIcon, size: 17, color: texte),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
