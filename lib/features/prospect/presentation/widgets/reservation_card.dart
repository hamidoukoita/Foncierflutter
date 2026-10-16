import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_statut_style.dart';

/// Carte d'une réservation de l'acquéreur : statut, bien, paiement, décompte et annulation.
class ReservationCard extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const ReservationCard({super.key, required this.reservation});

  @override
  ConsumerState<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends ConsumerState<ReservationCard> {
  bool _busy = false;

  Future<void> _annuler() async {
    setState(() => _busy = true);
    await annulerReservationAvecConfirmation(context, ref, widget.reservation);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final style = ReservationStatutStyle.de(r);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('DOSSIER ${r.numeroDossier}', style: AppTextStyles.overline)),
              StatusPill(label: style.libelle, color: style.couleur),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Text(r.bienDesignation ?? 'Bien non renseigné', style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
          if ((r.programmeNom ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                const Icon(Icons.apartment_rounded, size: 15, color: AppColors.primaryOcre),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(r.programmeNom!, style: AppTextStyles.bodyMedium)),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md - AppSpacing.xxs),
          _Chiffres(reservation: r),
          const SizedBox(height: AppSpacing.md - AppSpacing.xxs),
          _EtapeEnCours(reservation: r, style: style),
          if (r.estActive) ...[
            const SizedBox(height: AppSpacing.md),
            DetailButton(
              label: 'Annuler la réservation',
              icon: Icons.close_rounded,
              danger: true,
              compact: true,
              loading: _busy,
              onPressed: _annuler,
            ),
          ],
        ],
      ),
    );
  }
}

class _Chiffres extends StatelessWidget {
  final ReservationModel reservation;
  const _Chiffres({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: const BoxDecoration(color: AppColors.backgroundOffWhite, borderRadius: AppRadius.radiusLg),
      child: Row(
        children: [
          Expanded(child: _Chiffre('Prix du bien', CurrencyFormatter.fcfa(r.montant), mise: true)),
          Container(width: 1, height: 32, color: AppColors.borderLight),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: _Chiffre(
              r.estPayante ? 'Réservation payée' : 'Réservation',
              r.estPayante ? CurrencyFormatter.fcfa(r.montantReservation) : 'Gratuite',
            ),
          ),
        ],
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  final String libelle;
  final String valeur;
  final bool mise;
  const _Chiffre(this.libelle, this.valeur, {this.mise = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          valeur,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 15,
            color: mise ? AppColors.primaryOcreDark : AppColors.primaryBlueAnthracite,
          ),
        ),
      ],
    );
  }
}

/// Où en est le dossier : attente d'agent, décompte (avec jauge), vente, expiration ou annulation.
class _EtapeEnCours extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationStatutStyle style;
  const _EtapeEnCours({required this.reservation, required this.style});

  String get _message {
    final r = reservation;
    final paiement = r.estPayante && r.referencePaiement != null
        ? 'Payé par Orange Money (réf. ${r.referencePaiement}). '
        : '';
    switch (r.etape) {
      case StatutReservation.enAttente:
        return r.agentId == null
            ? '${paiement}La société va confier votre dossier à un agent.'
            : '$paiement${r.agentNom ?? 'Votre agent'} va vous contacter et démarrer votre réservation.';
      case StatutReservation.enCours:
        final echeance = r.dateExpiration;
        return echeance == null
            ? 'Votre réservation est en cours avec ${r.agentNom ?? 'votre agent'}.'
            : 'Le bien vous est réservé jusqu’au ${DateFormatter.date(echeance)} à ${DateFormatter.heure(echeance)} '
                'pour conclure la vente avec ${r.agentNom ?? 'votre agent'}.';
      case StatutReservation.vendue:
        return 'Félicitations, la vente est conclue${r.dateConclusion == null ? '' : ' le ${DateFormatter.date(r.dateConclusion!)}'}.';
      case StatutReservation.expiree:
        return 'Le délai est écoulé sans vente : le bien est de nouveau disponible et le montant de la réservation n’est pas rendu.';
      case StatutReservation.annulee:
        return r.rembourse
            ? 'Le bien a été vendu à un autre acquéreur : votre réservation vous est remboursée.'
            : r.motifAnnulation ?? 'Réservation annulée.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progression = reservation.isEnCours ? reservation.progression() : null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: BoxDecoration(color: style.fond, borderRadius: AppRadius.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(style.icone, size: 17, color: style.couleur),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _message,
                  style: AppTextStyles.label.copyWith(color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (progression != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.radiusRound,
              child: LinearProgressIndicator(
                value: 1 - progression,
                minHeight: 6,
                color: style.couleur,
                backgroundColor: AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
