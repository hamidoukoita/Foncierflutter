import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';

/// Phrases sur le remboursement d'une réservation que l'acquéreur annule lui-même,
/// selon le pourcentage fixé par la société (0 = rien, 100 = tout).
class RegleRemboursement {
  RegleRemboursement._();

  static double _part(double montant, int pourcentage) => (montant * pourcentage / 100).roundToDouble();

  /// Avant de payer : ce qui serait rendu en cas d'annulation.
  static String avantReservation(int pourcentage, double montant) {
    if (pourcentage <= 0) return 'Montant non remboursable si vous annulez votre réservation.';
    if (pourcentage >= 100) return 'Montant remboursé en totalité si vous annulez votre réservation.';
    return 'Si vous annulez votre réservation, $pourcentage % du montant vous est remboursé '
        '(${CurrencyFormatter.fcfa(_part(montant, pourcentage))}).';
  }

  /// Confirmation d'annulation : ce que l'acquéreur récupère vraiment.
  static String avantAnnulation(ReservationModel r) {
    final paye = CurrencyFormatter.fcfa(r.montantReservation);
    if (r.pourcentageRemboursement <= 0) return 'Les $paye payés pour la réservation ne vous seront pas remboursés.';
    if (r.pourcentageRemboursement >= 100) return 'Les $paye payés vous seront remboursés en totalité sur Orange Money.';
    return '${CurrencyFormatter.fcfa(r.remboursementSiAnnulation)} sur les $paye payés '
        '(${r.pourcentageRemboursement} %) vous seront remboursés sur Orange Money.';
  }

  /// Réservation annulée par l'acquéreur et remboursée (en tout ou en partie).
  static String apresAnnulation(ReservationModel r) {
    final rendu = CurrencyFormatter.fcfa(r.montantRembourse ?? 0);
    return r.pourcentageRemboursement >= 100
        ? 'Réservation annulée : vos $rendu vous ont été remboursés sur Orange Money.'
        : 'Réservation annulée : $rendu (${r.pourcentageRemboursement} % du montant payé) '
            'vous ont été remboursés sur Orange Money.';
  }
}
