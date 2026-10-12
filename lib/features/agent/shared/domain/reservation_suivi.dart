import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/bien_libelle.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';

/// État d'une réservation du point de vue du suivi agent.
enum EtatSuivi { enCours, expiree, confirmee }

extension ReservationSuiviX on ReservationModel {
  EtatSuivi etatSuivi([DateTime? maintenant]) {
    if (statut == 'CONFIRMER') return EtatSuivi.confirmee;
    final now = maintenant ?? DateTime.now();
    return now.isBefore(dateExpiration) ? EtatSuivi.enCours : EtatSuivi.expiree;
  }

  Duration tempsRestant([DateTime? maintenant]) {
    final restant = dateExpiration.difference(maintenant ?? DateTime.now());
    return restant.isNegative ? Duration.zero : restant;
  }

  /// "Lot 05 • Résidence Les Palmiers"
  String get titreSuivi => BienLibelle.joindre([
        BienLibelle.court(
          designation: bienDesignation,
          reference: bienReference,
          programmeNom: programmeNom,
        ),
        programmeNom,
      ]);
}

/// Présentation (libellé, couleurs) de l'état de suivi.
class EtatSuiviStyle {
  final String libelle;
  final Color fond;
  final Color couleur;
  final IconData icone;

  const EtatSuiviStyle(this.libelle, this.fond, this.couleur, this.icone);

  factory EtatSuiviStyle.de(ReservationModel reservation) {
    switch (reservation.etatSuivi()) {
      case EtatSuivi.confirmee:
        return const EtatSuiviStyle('Confirmée', AppColors.successGreenSoft,
            AppColors.successGreen, Icons.check_rounded);
      case EtatSuivi.expiree:
        return const EtatSuiviStyle('Expirée', AppColors.errorRedSoft,
            AppColors.errorRed, Icons.timer_off_outlined);
      case EtatSuivi.enCours:
        return EtatSuiviStyle(
          'Reste ${DateFormatter.dureeCourte(reservation.tempsRestant())}',
          AppColors.warningAmberSoft,
          AppColors.ambreReservation24h,
          Icons.hourglass_bottom_rounded,
        );
    }
  }
}

/// Sélection des réservations à suivre (hors refusées), les plus urgentes d'abord.
class ReservationsSuivi {
  ReservationsSuivi._();

  static List<ReservationModel> trier(List<ReservationModel> reservations) {
    final suivies = reservations.where((r) => r.statut != 'REFUSER').toList();
    int rang(ReservationModel r) => r.etatSuivi().index;
    suivies.sort((a, b) {
      final parEtat = rang(a).compareTo(rang(b));
      return parEtat != 0
          ? parEtat
          : a.dateExpiration.compareTo(b.dateExpiration);
    });
    return suivies;
  }

  static int dossiersEnCours(List<ReservationModel> reservations) =>
      reservations
          .where((r) =>
              r.statut != 'REFUSER' && r.etatSuivi() == EtatSuivi.enCours)
          .length;
}
