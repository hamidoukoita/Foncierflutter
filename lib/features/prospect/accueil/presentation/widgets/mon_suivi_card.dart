import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/bien_libelle.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import '../../domain/suivi_acquereur.dart';

/// Carte « Mon suivi » : réservation en cours (compte à rebours), confirmée,
/// prochaine visite. Invite à explorer quand rien n'est en cours.
class MonSuiviCard extends StatelessWidget {
  final SuiviAcquereur suivi;
  final VoidCallback onReservations;
  final VoidCallback onVisites;
  final VoidCallback onExplorer;

  const MonSuiviCard({
    super.key,
    required this.suivi,
    required this.onReservations,
    required this.onVisites,
    required this.onExplorer,
  });

  static String _titreReservation(ReservationModel r) => BienLibelle.joindre([
        BienLibelle.court(
          designation: r.bienDesignation,
          reference: r.bienReference,
          programmeNom: r.programmeNom,
        ),
        r.programmeNom,
      ]);

  @override
  Widget build(BuildContext context) {
    final lignes = <Widget>[
      if (suivi.reservationEnCours case final r?)
        _SuiviLigne(
          icone: Icons.hourglass_bottom_rounded,
          titre: _titreReservation(r),
          detail: 'Option en attente du promoteur',
          etiquette:
              'Reste ${DateFormatter.dureeCourte(r.dateExpiration.difference(DateTime.now()))}',
          couleurEtiquette: AppColors.primaryOcreLight,
          onTap: onReservations,
        ),
      if (suivi.reservationConfirmee case final r?)
        _SuiviLigne(
          icone: Icons.verified_rounded,
          titre: _titreReservation(r),
          detail: 'Réservation confirmée · dossier à finaliser au siège',
          etiquette: 'Confirmée',
          couleurEtiquette: AppColors.successGreenSoft,
          onTap: onReservations,
        ),
      if (suivi.prochaineVisite case final v?)
        _SuiviLigne(
          icone: Icons.event_available_rounded,
          titre: v.localisation.isEmpty ? 'Visite programmée' : v.localisation,
          detail:
              '${DateFormatter.jourRelatif(v.debut)} · ${DateFormatter.plageHoraire(v.debut, v.fin)} · ${v.isChantier ? 'Sur chantier' : 'Au siège'}',
          etiquette: v.isAccepte ? 'Confirmée' : 'En attente',
          couleurEtiquette: v.isAccepte
              ? AppColors.successGreenSoft
              : AppColors.warningAmberSoft,
          onTap: onVisites,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
      decoration: BoxDecoration(
        gradient: AppGradients.navy,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MON SUIVI',
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.primaryOcreLight)),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          if (lignes.isEmpty)
            _SuiviVide(onExplorer: onExplorer)
          else
            for (var i = 0; i < lignes.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(color: AppColors.primaryBlueSoft),
                ),
              lignes[i],
            ],
        ],
      ),
    );
  }
}

class _SuiviLigne extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String detail;
  final String etiquette;
  final Color couleurEtiquette;
  final VoidCallback onTap;

  const _SuiviLigne({
    required this.icone,
    required this.titre,
    required this.detail,
    required this.etiquette,
    required this.couleurEtiquette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.primaryBlueSoft, shape: BoxShape.circle),
            child: Icon(icone, size: 20, color: AppColors.primaryOcreLight),
          ),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle
                      .copyWith(color: AppColors.white, fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.onDarkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
                color: couleurEtiquette, borderRadius: AppRadius.radiusRound),
            child: Text(
              etiquette,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBlueAnthracite,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuiviVide extends StatelessWidget {
  final VoidCallback onExplorer;
  const _SuiviVide({required this.onExplorer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Aucune démarche en cours. Réservez un lot ou planifiez une visite : tout votre suivi apparaîtra ici.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.onDarkMuted, height: 1.45),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        InkWell(
          onTap: onExplorer,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.cta,
              shape: BoxShape.circle,
              boxShadow: AppShadows.cta,
            ),
            child:
                const Icon(Icons.arrow_forward_rounded, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
