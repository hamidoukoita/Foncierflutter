import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';

/// Libellé, couleurs et icône d'une réservation, communs aux écrans acquéreur et agent.
class ReservationStatutStyle {
  final String libelle;
  final Color couleur;
  final Color fond;
  final IconData icone;

  const ReservationStatutStyle(this.libelle, this.couleur, this.fond, this.icone);

  factory ReservationStatutStyle.de(ReservationModel r, [DateTime? maintenant]) {
    switch (r.etape) {
      case StatutReservation.enAttente:
        return r.agentId == null
            ? const ReservationStatutStyle('En attente d’un agent', AppColors.ambreReservation24h,
                AppColors.warningAmberSoft, Icons.hourglass_top_rounded)
            : const ReservationStatutStyle('Agent attribué', AppColors.primaryBlueAnthracite,
                AppColors.grey100, Icons.support_agent_rounded);
      case StatutReservation.enCours:
        final restant = r.tempsRestant(maintenant);
        return ReservationStatutStyle(
          restant == null ? 'En cours' : 'Reste ${DateFormatter.dureeLisible(restant)}',
          AppColors.primaryOcreDark,
          AppColors.primaryOcreSoft,
          Icons.timer_outlined,
        );
      case StatutReservation.vendue:
        return const ReservationStatutStyle('Vendue', AppColors.successGreen, AppColors.successGreenSoft, Icons.verified_rounded);
      case StatutReservation.expiree:
        return const ReservationStatutStyle('Expirée', AppColors.errorRed, AppColors.errorRedSoft, Icons.timer_off_outlined);
      case StatutReservation.annulee:
        switch (r.suiteVente) {
          case SuiteVente.aChoisir:
            return const ReservationStatutStyle('Votre choix', AppColors.ambreReservation24h,
                AppColors.warningAmberSoft, Icons.swap_horiz_rounded);
          case SuiteVente.remboursementEnCours:
            return const ReservationStatutStyle('Remboursement', AppColors.primaryBlueAnthracite,
                AppColors.grey100, Icons.schedule_rounded);
          case SuiteVente.remplacee:
            return const ReservationStatutStyle('Reportée', AppColors.primaryBlueAnthracite,
                AppColors.grey100, Icons.swap_horiz_rounded);
          case SuiteVente.remboursee:
          case null:
            return r.rembourse
                ? const ReservationStatutStyle('Remboursée', AppColors.grey700, AppColors.grey100, Icons.currency_exchange_rounded)
                : const ReservationStatutStyle('Annulée', AppColors.grey600, AppColors.grey100, Icons.block_rounded);
        }
    }
  }
}
