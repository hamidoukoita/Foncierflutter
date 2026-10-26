import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import '../../domain/projet_construction.dart';

enum _Etat { fait, enCours, aVenir, echec }

class _Jalon {
  final String titre;
  final String? detail;
  final _Etat etat;
  const _Jalon(this.titre, this.etat, [this.detail]);
}

/// Frise du dossier : envoi → étude → décision → travaux → livraison.
class ProjetSuivi extends StatelessWidget {
  final ProjetConstruction projet;
  const ProjetSuivi({super.key, required this.projet});

  List<_Jalon> get _jalons {
    final envoye =
        projet.dateDemande != null ? 'Le ${DateFormatter.dateLongue(projet.dateDemande!)}' : null;
    switch (projet.statut) {
      case StatutProjet.enEtude:
        return [
          _Jalon('Dossier envoyé', _Etat.fait, envoye),
          _Jalon('Étude par le promoteur', _Etat.enCours,
              '${projet.societeNom ?? 'Le promoteur'} examine votre terrain et votre projet.'),
          const _Jalon('Décision', _Etat.aVenir),
          const _Jalon('Travaux', _Etat.aVenir),
        ];
      case StatutProjet.enDiscussion:
        return [
          _Jalon('Dossier envoyé', _Etat.fait, envoye),
          _Jalon('Échanges avec le promoteur', _Etat.enCours,
              '${projet.societeNom ?? 'Le promoteur'} vous a répondu : consultez la discussion ci-dessous.'),
          const _Jalon('Accord', _Etat.aVenir),
          const _Jalon('Travaux', _Etat.aVenir),
        ];
      case StatutProjet.refuse:
        return [
          _Jalon('Dossier envoyé', _Etat.fait, envoye),
          const _Jalon('Étude par le promoteur', _Etat.fait),
          _Jalon('Projet refusé', _Etat.echec, projet.motifRefus ?? 'Aucun motif communiqué.'),
        ];
      case StatutProjet.accepte:
        final termine = projet.progression >= 100;
        return [
          _Jalon('Dossier envoyé', _Etat.fait, envoye),
          _Jalon(
            'Projet accepté',
            _Etat.fait,
            projet.propositionRetenue == null
                ? null
                : 'Proposition n°${projet.propositionRetenue!.numero} retenue : ${projet.propositionRetenue!.titre}',
          ),
          _Jalon(
            projet.etapeAvancement ?? 'Travaux',
            termine ? _Etat.fait : _Etat.enCours,
            [
              '${projet.progression} % réalisé',
              if ((projet.commentaireAvancement ?? '').isNotEmpty) projet.commentaireAvancement!,
            ].join(' · '),
          ),
          _Jalon('Livraison', termine ? _Etat.fait : _Etat.aVenir),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final jalons = _jalons;
    return Column(
      children: [
        for (var i = 0; i < jalons.length; i++)
          _LigneJalon(jalon: jalons[i], dernier: i == jalons.length - 1),
      ],
    );
  }
}

class _LigneJalon extends StatelessWidget {
  final _Jalon jalon;
  final bool dernier;
  const _LigneJalon({required this.jalon, required this.dernier});

  @override
  Widget build(BuildContext context) {
    final (couleur, icone) = switch (jalon.etat) {
      _Etat.fait => (AppColors.successGreen, Icons.check_rounded),
      _Etat.enCours => (AppColors.primaryOcre, Icons.more_horiz_rounded),
      _Etat.echec => (AppColors.errorRed, Icons.close_rounded),
      _Etat.aVenir => (AppColors.grey400, null),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: jalon.etat == _Etat.aVenir ? AppColors.white : couleur,
                  border: Border.all(color: couleur, width: 2),
                ),
                child: icone == null ? null : Icon(icone, size: 14, color: AppColors.white),
              ),
              if (!dernier)
                Expanded(
                  child: Container(
                    width: 2,
                    color: jalon.etat == _Etat.fait ? AppColors.successGreen : AppColors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: dernier ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jalon.titre,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: jalon.etat == _Etat.aVenir ? AppColors.textMuted : AppColors.primaryBlueAnthracite,
                      )),
                  if (jalon.detail != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(jalon.detail!,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: jalon.etat == _Etat.echec ? AppColors.errorRed : AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
