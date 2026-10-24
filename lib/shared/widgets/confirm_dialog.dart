import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_action_button.dart';

/// Boîte de confirmation Foncier+ (pictogramme, titre, message, 2 actions).
class ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  const ConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Annuler',
    this.destructive = false,
  });

  /// Affiche la boîte ; renvoie `true` uniquement si l'utilisateur confirme.
  static Future<bool> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Annuler',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        icon: icon,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  /// Marge intérieure horizontale d'un [AppActionButton] (des deux côtés).
  static const double _margeBouton = 2 * (AppSpacing.sm + AppSpacing.xs);

  /// Vrai si [libelle] s'écrit en entier dans un bouton de largeur [largeur].
  static bool _tient(BuildContext context, String libelle, double largeur) {
    final mesure = TextPainter(
      text: TextSpan(
        text: libelle,
        style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final tient = mesure.width <= largeur - _margeBouton;
    mesure.dispose();
    return tient;
  }

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.errorRed : AppColors.primaryOcre;
    final accentSoft =
        destructive ? AppColors.errorRedSoft : AppColors.warningAmberSoft;

    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration:
                  BoxDecoration(color: accentSoft, shape: BoxShape.circle),
              child: Icon(icon, color: accent, size: 26),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, contraintes) {
                final annuler = AppActionButton(
                  label: cancelLabel,
                  height: 48,
                  onPressed: () => Navigator.of(context).pop(false),
                );
                final confirmer = AppActionButton(
                  label: confirmLabel,
                  height: 48,
                  variant: destructive
                      ? AppActionVariant.danger
                      : AppActionVariant.accent,
                  onPressed: () => Navigator.of(context).pop(true),
                );
                // Côte à côte si les deux libellés tiennent en entier, sinon l'un sous l'autre.
                final demiLargeur = (contraintes.maxWidth - AppSpacing.md) / 2;
                if (_tient(context, confirmLabel, demiLargeur) &&
                    _tient(context, cancelLabel, demiLargeur)) {
                  return Row(
                    children: [
                      Expanded(child: annuler),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: confirmer),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    confirmer,
                    const SizedBox(height: AppSpacing.sm),
                    annuler,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
