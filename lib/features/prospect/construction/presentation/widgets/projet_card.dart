import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import '../../domain/projet_construction.dart';
import 'projet_statut.dart';

/// Résumé d'un projet : modèle, société, statut et avancement.
class ProjetCard extends StatelessWidget {
  final ProjetConstruction projet;
  final VoidCallback onTap;

  const ProjetCard({super.key, required this.projet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accepte = projet.statut == StatutProjet.accepte;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.constructionMint, borderRadius: AppRadius.radiusMd),
                child: const Icon(Icons.home_work_outlined, color: AppColors.constructionGreen),
              ),
              const SizedBox(width: AppSpacing.md - AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(projet.libelleModele,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle),
                    Text(
                      [projet.societeNom, projet.numeroDossier].whereType<String>().join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              ProjetStatutPill(statut: projet.statut),
            ],
          ),
          const SizedBox(height: AppSpacing.md - AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(projet.etapeAvancement ?? 'Dossier reçu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w700)),
              ),
              if (accepte)
                Text('${projet.progression} %',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.successGreen, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.radiusRound,
            child: LinearProgressIndicator(
              value: switch (projet.statut) {
                StatutProjet.enEtude => 0.08,
                StatutProjet.accepte => projet.progression / 100,
                StatutProjet.refuse => 1,
              },
              minHeight: 6,
              backgroundColor: AppColors.grey200,
              color: projet.statut.couleur,
            ),
          ),
        ],
      ),
    );
  }
}
