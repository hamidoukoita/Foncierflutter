import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/icon_label.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';

/// Carte sombre mettant en avant la prochaine visite à mener.
class ProchaineVisiteCard extends StatelessWidget {
  final RendezVousModel? visite;
  final VoidCallback? onTap;
  final VoidCallback? onAppeler;
  final VoidCallback? onItineraire;

  const ProchaineVisiteCard({
    super.key,
    required this.visite,
    this.onTap,
    this.onAppeler,
    this.onItineraire,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.navy,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.floating,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: visite == null ? null : onTap,
          borderRadius: AppRadius.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
            child: visite == null ? _buildVide() : _buildVisite(visite!),
          ),
        ),
      ),
    );
  }

  Widget _buildVide() {
    return Row(
      children: [
        const Icon(Icons.event_available_rounded, color: AppColors.onDarkMuted),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Aucune visite à venir pour le moment.',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildVisite(RendezVousModel v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SoftBadge(
              label: 'PROCHAINE VISITE',
              background: AppColors.primaryOcre,
              foreground: AppColors.white,
            ),
            const Spacer(),
            Text(
              DateFormatter.plageHoraire(v.debut, v.fin),
              style: AppTextStyles.mono.copyWith(color: AppColors.white),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          v.acquereurNom ?? 'Prospect',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        IconLabel(
          icon: Icons.location_on_rounded,
          iconColor: AppColors.primaryOcre,
          text: v.localisation,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Divider(height: 1, color: AppColors.primaryBlueSoft),
        ),
        Row(
          children: [
            Expanded(
              child: AppActionButton(
                label: 'Appeler',
                icon: Icons.phone_rounded,
                variant: AppActionVariant.darkSubtle,
                height: 48,
                onPressed: onAppeler,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppActionButton(
                label: 'Itinéraire GPS',
                icon: Icons.explore_outlined,
                variant: AppActionVariant.accent,
                height: 48,
                onPressed: onItineraire,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
