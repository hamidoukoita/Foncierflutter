import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

/// Cadre des fenêtres de compte (nom, numéro, mot de passe), communes à l'acquéreur et à l'agent :
/// pastille, titre, champs et actions.
class CompteDialog extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final GlobalKey<FormState> formKey;
  final List<Widget> champs;
  final String libelleAction;
  final bool enCours;
  final VoidCallback onValider;

  const CompteDialog({
    super.key,
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.formKey,
    required this.champs,
    required this.libelleAction,
    required this.enCours,
    required this.onValider,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: AppColors.primaryOcreSoft, shape: BoxShape.circle),
                  child: Icon(icone, color: AppColors.primaryOcre, size: 26),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(titre, textAlign: TextAlign.center, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(sousTitre, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < champs.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                champs[i],
              ],
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(text: libelleAction, icon: Icons.check_rounded, isLoading: enCours, onPressed: onValider),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.radiusMd,
                child: AppActionButton(
                  label: 'Annuler',
                  height: 44,
                  onPressed: enCours ? null : () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
