import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';

/// Statut d'une visite tel que présenté à l'agent.
///
/// Le backend ne connaît que EN_ATTENTE / ACCEPTER / REFUSER :
/// « Effectuée » est déduit (visite acceptée terminée ou avec compte-rendu).
enum VisiteStatut {
  aReconfirmer('À reconfirmer', AppColors.ambreSoft,
      AppColors.ambreReservation24h, null),
  confirmee('Confirmée', AppColors.successGreenSoft, AppColors.successGreen,
      Icons.check_rounded),
  effectuee('Effectuée', AppColors.grey100, AppColors.primaryBlueAnthracite,
      Icons.done_all_rounded),
  refusee('Refusée', AppColors.errorRedSoft, AppColors.errorRed,
      Icons.close_rounded);

  final String libelle;
  final Color fond;
  final Color couleur;
  final IconData? icone;

  const VisiteStatut(this.libelle, this.fond, this.couleur, this.icone);
}

extension RendezVousStatutX on RendezVousModel {
  VisiteStatut statutVisite([DateTime? maintenant]) {
    final now = maintenant ?? DateTime.now();
    switch (statut) {
      case 'REFUSER':
        return VisiteStatut.refusee;
      case 'ACCEPTER':
        return (aCompteRendu || fin.isBefore(now))
            ? VisiteStatut.effectuee
            : VisiteStatut.confirmee;
      default:
        return VisiteStatut.aReconfirmer;
    }
  }

  /// Visite encore à mener (ni refusée, ni effectuée).
  bool estAMener([DateTime? maintenant]) {
    final s = statutVisite(maintenant);
    return s == VisiteStatut.aReconfirmer || s == VisiteStatut.confirmee;
  }
}
