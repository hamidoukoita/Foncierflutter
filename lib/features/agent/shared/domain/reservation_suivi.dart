import 'package:flutter_mobile_prospect_agent/core/utils/bien_libelle.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';

extension ReservationSuiviX on ReservationModel {
  /// « Lot 05 • Résidence Les Palmiers »
  String get titreSuivi => BienLibelle.joindre([
        BienLibelle.court(
          designation: bienDesignation,
          reference: bienReference,
          programmeNom: programmeNom,
        ),
        programmeNom,
      ]);

  /// L'agent peut lancer le décompte : réservation payée, prise en charge, pas encore démarrée.
  bool get aDemarrer => isEnAttente;

  /// Décompte en cours et non échu : la vente peut être conclue.
  bool peutConclure([DateTime? maintenant]) =>
      isEnCours && (dateExpiration == null || (maintenant ?? DateTime.now()).isBefore(dateExpiration!));
}

/// Ordre de travail de l'agent : réservations à démarrer (les plus anciennes d'abord),
/// décomptes en cours (échéance la plus proche d'abord), puis dossiers terminés (les plus récents).
class ReservationsSuivi {
  ReservationsSuivi._();

  static int _rang(ReservationModel r) => r.isEnAttente ? 0 : r.isEnCours ? 1 : 2;

  static List<ReservationModel> trier(List<ReservationModel> reservations) {
    final liste = [...reservations];
    liste.sort((a, b) {
      final parRang = _rang(a).compareTo(_rang(b));
      if (parRang != 0) return parRang;
      if (a.isEnCours) {
        final fin = DateTime(9999);
        return (a.dateExpiration ?? fin).compareTo(b.dateExpiration ?? fin);
      }
      if (a.isEnAttente) return a.dateReservation.compareTo(b.dateReservation);
      return b.dateReservation.compareTo(a.dateReservation);
    });
    return liste;
  }

  /// Dossiers qui demandent encore une action de l'agent.
  static int dossiersEnCours(List<ReservationModel> reservations) =>
      reservations.where((r) => r.estActive).length;
}
