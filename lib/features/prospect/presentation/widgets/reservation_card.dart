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

/// Carte d'une réservation de l'acquéreur : statut, bien, montant, délai et annulation.
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
    final etat = _EtatReservation.de(r, DateTime.now());

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('DOSSIER ${r.numeroDossier}',
                      style: AppTextStyles.overline)),
              StatusPill(label: etat.libelle, color: etat.couleur),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Text(r.bienDesignation ?? 'Bien non renseigné',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
          if ((r.programmeNom ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                const Icon(Icons.apartment_rounded,
                    size: 15, color: AppColors.primaryOcre),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                    child:
                        Text(r.programmeNom!, style: AppTextStyles.bodyMedium)),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md - AppSpacing.xxs),
          _Chiffres(reservation: r),
          if (etat.enCours) ...[
            const SizedBox(height: AppSpacing.md - AppSpacing.xxs),
            _DelaiRestant(reservation: r),
          ],
          if (r.statut == 'REFUSER' &&
              (r.motifRefus ?? '').isNotEmpty &&
              !r.isAnnulee) ...[
            const SizedBox(height: AppSpacing.md - AppSpacing.xs),
            Text(
              'Motif : ${r.motifRefus}',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.errorRed, fontWeight: FontWeight.w600),
            ),
          ],
          if (r.isEnAttente) ...[
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

/// Libellé et couleur d'une réservation (le délai vient du backend : `dateExpiration`).
class _EtatReservation {
  final String libelle;
  final Color couleur;
  final bool enCours;

  const _EtatReservation(this.libelle, this.couleur, {this.enCours = false});

  factory _EtatReservation.de(ReservationModel r, DateTime maintenant) {
    if (r.isAnnulee) {
      return const _EtatReservation('Annulée', AppColors.grey600);
    }
    if (r.isEnAttente) {
      return maintenant.isBefore(r.dateExpiration)
          ? const _EtatReservation('En attente', AppColors.ambreReservation24h,
              enCours: true)
          : const _EtatReservation('Expirée', AppColors.errorRed);
    }
    if (r.statut == 'CONFIRMER') {
      return const _EtatReservation('Confirmée', AppColors.successGreen);
    }
    return const _EtatReservation('Refusée', AppColors.errorRed);
  }
}

class _Chiffres extends StatelessWidget {
  final ReservationModel reservation;
  const _Chiffres({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: const BoxDecoration(
          color: AppColors.backgroundOffWhite,
          borderRadius: AppRadius.radiusLg),
      child: Row(
        children: [
          Expanded(
              child: _Chiffre(
                  'Montant', CurrencyFormatter.fcfa(reservation.montant),
                  mise: true)),
          Container(width: 1, height: 32, color: AppColors.borderLight),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
              child: _Chiffre('Demandée le',
                  DateFormatter.date(reservation.dateReservation))),
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
            color: mise
                ? AppColors.primaryOcreDark
                : AppColors.primaryBlueAnthracite,
          ),
        ),
      ],
    );
  }
}

/// Délai de gel restant, avec barre de progression.
class _DelaiRestant extends StatelessWidget {
  final ReservationModel reservation;
  const _DelaiRestant({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final total =
        reservation.dateExpiration.difference(reservation.dateReservation);
    final restant = reservation.dateExpiration.difference(DateTime.now());
    final ratio = total.inSeconds <= 0
        ? 0.0
        : (restant.inSeconds / total.inSeconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: const BoxDecoration(
          color: AppColors.warningAmberSoft, borderRadius: AppRadius.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_bottom_rounded,
                  size: 17, color: AppColors.ambreReservation24h),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'En attente du promoteur · reste ${DateFormatter.dureeCourte(restant)}',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryOcreDark,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.radiusRound,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: AppColors.ambreReservation24h,
              backgroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
