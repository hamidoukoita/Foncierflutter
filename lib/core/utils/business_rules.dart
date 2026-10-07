class BusinessRules {
  BusinessRules._();

  /// La réservation conservatoire gèle le lot/parcelle pendant strictement 24 heures.
  static const Duration dureeGelReservation = Duration(hours: 24);

  /// Vérifie si une réservation est toujours active selon la règle des 24h.
  ///
  /// Si la date de réservation + 24h est dans le futur et que le statut n'est pas refusé.
  static bool isReservationActive(DateTime dateReservation, String statut) {
    if (statut == 'REFUSER') return false;
    if (statut == 'CONFIRMER') return true;

    final dateExpiration = dateReservation.add(dureeGelReservation);
    return DateTime.now().isBefore(dateExpiration);
  }

  /// Calcule le temps restant pour une réservation en attente.
  static Duration tempsRestantReservation(DateTime dateReservation) {
    final dateExpiration = dateReservation.add(dureeGelReservation);
    final now = DateTime.now();
    if (now.isAfter(dateExpiration)) {
      return Duration.zero;
    }
    return dateExpiration.difference(now);
  }
}
