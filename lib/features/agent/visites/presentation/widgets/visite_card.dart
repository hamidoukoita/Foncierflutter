import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/visite_statut.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/time_range_chip.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/visite_statut_badge.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/icon_label.dart';

/// Carte d'une visite assignée (horaire, prospect, bien, actions).
class VisiteCard extends StatelessWidget {
  final RendezVousModel visite;
  final bool estProchaine;
  final bool afficherJour;
  final VoidCallback onAppeler;
  final VoidCallback onItineraire;
  final VoidCallback onDetails;

  const VisiteCard({
    super.key,
    required this.visite,
    required this.onAppeler,
    required this.onItineraire,
    required this.onDetails,
    this.estProchaine = false,
    this.afficherJour = false,
  });

  String get _horaire {
    final plage = DateFormatter.plageHoraire(visite.debut, visite.fin);
    return afficherJour
        ? '${DateFormatter.jourRelatif(visite.debut)} $plage'
        : plage;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      highlighted: estProchaine,
      onTap: onDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TimeRangeChip(label: _horaire, highlighted: estProchaine),
              const Spacer(),
              VisiteStatutBadge(statut: visite.statutVisite()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            visite.acquereurNom ?? 'Prospect',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.xs),
          IconLabel(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.errorRed,
            text: visite.localisation,
          ),
          const SizedBox(height: 2),
          IconLabel(
            icon: Icons.phone_rounded,
            iconColor: AppColors.primaryBlueAnthracite,
            text: visite.acquereurTelephone ?? '—',
            style: AppTextStyles.mono,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          Row(
            children: [
              Expanded(
                child: AppActionButton(
                  label: 'Appeler',
                  icon: Icons.phone_rounded,
                  onPressed: onAppeler,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppActionButton(
                  label: 'Itinéraire',
                  icon: Icons.explore_outlined,
                  onPressed: onItineraire,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppActionButton(
                  label: 'Détails',
                  trailingIcon: Icons.chevron_right_rounded,
                  variant: AppActionVariant.dark,
                  onPressed: onDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
