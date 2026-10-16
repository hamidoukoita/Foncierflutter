import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';

/// Démarches en cours de l'acquéreur, résumées sur l'accueil.
class SuiviAcquereur {
  /// Réservation qui bloque encore le bien : décompte en cours (le plus proche de l'échéance)
  /// ou, à défaut, en attente de prise en charge par un agent.
  final ReservationModel? reservationEnCours;

  /// Dernière vente conclue.
  final ReservationModel? reservationVendue;

  /// Prochaine visite non refusée.
  final RendezVousModel? prochaineVisite;

  const SuiviAcquereur({
    this.reservationEnCours,
    this.reservationVendue,
    this.prochaineVisite,
  });

  bool get estVide =>
      reservationEnCours == null &&
      reservationVendue == null &&
      prochaineVisite == null;

  factory SuiviAcquereur.depuis(
    List<ReservationModel> reservations,
    List<RendezVousModel> visites,
    DateTime maintenant,
  ) {
    // Un décompte échu attend son expiration côté serveur : il ne bloque plus rien.
    bool enVigueur(ReservationModel r) =>
        r.isEnAttente || (r.isEnCours && (r.dateExpiration == null || maintenant.isBefore(r.dateExpiration!)));
    final decomptes = reservations.where((r) => r.isEnCours && enVigueur(r)).toList()
      ..sort((a, b) => (a.dateExpiration ?? maintenant).compareTo(b.dateExpiration ?? maintenant));
    final enAttente = reservations.where((r) => r.isEnAttente).toList()
      ..sort((a, b) => b.dateReservation.compareTo(a.dateReservation));
    final enCours = [...decomptes, ...enAttente];
    final vendues = reservations.where((r) => r.isVendue).toList()
      ..sort((a, b) => (b.dateConclusion ?? b.dateReservation).compareTo(a.dateConclusion ?? a.dateReservation));
    final aVenir = visites
        .where((v) => !v.isRefuse && v.fin.isAfter(maintenant))
        .toList()
      ..sort((a, b) => a.debut.compareTo(b.debut));

    return SuiviAcquereur(
      reservationEnCours: enCours.isEmpty ? null : enCours.first,
      reservationVendue: vendues.isEmpty ? null : vendues.first,
      prochaineVisite: aVenir.isEmpty ? null : aVenir.first,
    );
  }
}
