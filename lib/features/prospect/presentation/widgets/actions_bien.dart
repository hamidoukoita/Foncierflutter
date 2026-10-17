import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';

/// Ce que l'acquéreur peut faire sur un bien (lot, parcelle, maison), d'après le serveur :
/// un bien vendu n'offre plus aucune action ; un bien complet (nombre maximal de réservations
/// atteint) n'accepte ni réservation ni visite, sauf la visite pour qui l'a déjà réservé ;
/// un rendez-vous déjà prévu sur le bien ferme la prise d'un second.
class ActionsBien {
  final bool vendu;
  final bool peutReserver;
  final bool peutVisiter;

  /// Raison affichée quand une action est fermée (null si tout est possible).
  final String? motif;

  const ActionsBien({required this.vendu, required this.peutReserver, required this.peutVisiter, this.motif});

  /// Tant que les conditions se chargent, on s'appuie sur le statut du bien.
  factory ActionsBien.depuis(ConditionsReservation? conditions, {required bool vendu, required bool reservableParStatut}) {
    if (vendu || (conditions?.vendu ?? false)) {
      return const ActionsBien(vendu: true, peutReserver: false, peutVisiter: false, motif: 'Ce bien est vendu.');
    }
    if (conditions == null) {
      return ActionsBien(vendu: false, peutReserver: reservableParStatut, peutVisiter: true);
    }
    final peutReserver = conditions.reservable;
    final peutVisiter = conditions.visitePossible;
    // Réservation fermée (hors « déjà réservé par moi », signalé ailleurs), sinon visite fermée
    // (par exemple un rendez-vous déjà prévu).
    String? motif = !peutReserver && !conditions.dejaReserveParMoi ? conditions.motifIndisponibilite : null;
    if (!peutVisiter) motif ??= conditions.motifVisiteImpossible;
    return ActionsBien(vendu: false, peutReserver: peutReserver, peutVisiter: peutVisiter, motif: motif);
  }

  /// Aucune action à proposer : la barre du bas est masquée.
  bool get aucuneAction => !peutReserver && !peutVisiter;
}
