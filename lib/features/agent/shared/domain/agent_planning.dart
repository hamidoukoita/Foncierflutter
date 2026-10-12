import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'visite_statut.dart';

/// Règles de tri et de sélection des visites de l'agent (logique pure, testable).
class AgentPlanning {
  AgentPlanning._();

  static List<RendezVousModel> _parDebut(Iterable<RendezVousModel> visites) =>
      visites.toList()..sort((a, b) => a.debut.compareTo(b.debut));

  /// Visites (non refusées) d'un jour donné.
  static List<RendezVousModel> duJour(
    List<RendezVousModel> visites,
    DateTime jour,
  ) =>
      _parDebut(visites.where((v) =>
          DateFormatter.estMemeJour(v.debut, jour) &&
          v.statutVisite() != VisiteStatut.refusee));

  /// Visites à mener après aujourd'hui.
  static List<RendezVousModel> aVenir(
    List<RendezVousModel> visites,
    DateTime maintenant,
  ) {
    final demain =
        DateFormatter.debutDuJour(maintenant).add(const Duration(days: 1));
    return _parDebut(visites
        .where((v) => !v.debut.isBefore(demain) && v.estAMener(maintenant)));
  }

  /// Visites effectuées, de la plus récente à la plus ancienne.
  static List<RendezVousModel> effectuees(
    List<RendezVousModel> visites,
    DateTime maintenant,
  ) =>
      _parDebut(visites.where(
              (v) => v.statutVisite(maintenant) == VisiteStatut.effectuee))
          .reversed
          .toList();

  /// Prochaine visite à mener (en cours ou à venir).
  static RendezVousModel? prochaine(
    List<RendezVousModel> visites,
    DateTime maintenant,
  ) {
    final candidates = _parDebut(visites
        .where((v) => v.fin.isAfter(maintenant) && v.estAMener(maintenant)));
    return candidates.isEmpty ? null : candidates.first;
  }

  /// Le jour contient-il au moins une visite à mener ?
  static bool aDesVisites(
    List<RendezVousModel> visites,
    DateTime jour,
  ) =>
      visites.any(
          (v) => DateFormatter.estMemeJour(v.debut, jour) && v.estAMener());
}
