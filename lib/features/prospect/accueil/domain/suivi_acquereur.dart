import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';

/// Démarches en cours de l'acquéreur, résumées sur l'accueil.
class SuiviAcquereur {
  /// Option posée, encore dans son délai de gel.
  final ReservationModel? reservationEnCours;

  /// Réservation acceptée par la société (dossier à finaliser au siège).
  final ReservationModel? reservationConfirmee;

  /// Prochaine visite non refusée.
  final RendezVousModel? prochaineVisite;

  const SuiviAcquereur({
    this.reservationEnCours,
    this.reservationConfirmee,
    this.prochaineVisite,
  });

  bool get estVide =>
      reservationEnCours == null &&
      reservationConfirmee == null &&
      prochaineVisite == null;

  factory SuiviAcquereur.depuis(
    List<ReservationModel> reservations,
    List<RendezVousModel> visites,
    DateTime maintenant,
  ) {
    final enCours = reservations
        .where((r) =>
            r.statut == 'EN_ATTENTE' && maintenant.isBefore(r.dateExpiration))
        .toList()
      ..sort((a, b) => a.dateExpiration.compareTo(b.dateExpiration));
    final confirmees = reservations
        .where((r) => r.statut == 'CONFIRMER')
        .toList()
      ..sort((a, b) => b.dateReservation.compareTo(a.dateReservation));
    final aVenir = visites
        .where((v) => !v.isRefuse && v.fin.isAfter(maintenant))
        .toList()
      ..sort((a, b) => a.debut.compareTo(b.debut));

    return SuiviAcquereur(
      reservationEnCours: enCours.isEmpty ? null : enCours.first,
      reservationConfirmee: confirmees.isEmpty ? null : confirmees.first,
      prochaineVisite: aVenir.isEmpty ? null : aVenir.first,
    );
  }
}
