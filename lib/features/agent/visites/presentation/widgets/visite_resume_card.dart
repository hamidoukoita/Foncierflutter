import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/visite_statut.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/time_range_chip.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/visite_statut_badge.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/icon_label.dart';

/// En-tête de la fiche visite : horaire, prospect, bien et actions de terrain.
class VisiteResumeCard extends StatelessWidget {
  final RendezVousModel visite;
  final BienFoncierModel? bien;
  final VoidCallback onAppeler;
  final VoidCallback onLocaliser;

  const VisiteResumeCard({
    super.key,
    required this.visite,
    required this.bien,
    required this.onAppeler,
    required this.onLocaliser,
  });

  String? get _ligneTechnique {
    final b = bien;
    if (b == null) return null;
    final superficie = 'Superficie : ${b.superficie.toStringAsFixed(0)} m²';
    return b.numeroTitreFoncier == null
        ? superficie
        : '$superficie (TF N° ${b.numeroTitreFoncier})';
  }

  @override
  Widget build(BuildContext context) {
    final statut = visite.statutVisite();
    final horaire =
        '${DateFormatter.jourRelatif(visite.debut)} ${DateFormatter.plageHoraire(visite.debut, visite.fin)}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TimeRangeChip(
                label: horaire,
                highlighted: statut != VisiteStatut.effectuee,
              ),
              const Spacer(),
              VisiteStatutBadge(statut: statut),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(visite.acquereurNom ?? 'Prospect', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.xs),
          IconLabel(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.errorRed,
            text: visite.localisation,
          ),
          if (_ligneTechnique != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(_ligneTechnique!, style: AppTextStyles.mono),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          Row(
            children: [
              Expanded(
                child: AppActionButton(
                  label: 'Appeler le client',
                  icon: Icons.phone_rounded,
                  variant: AppActionVariant.dark,
                  height: 44,
                  onPressed: onAppeler,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppActionButton(
                  label: 'Localisation',
                  icon: Icons.explore_outlined,
                  height: 44,
                  onPressed: onLocaliser,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
