import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/business_rules.dart';

void main() {
  group('BusinessRules - Règle des 24h de réservation', () {
    test(
        'isReservationActive doit retourner vrai si la réservation a moins de 24h et est EN_ATTENTE',
        () {
      final now = DateTime.now();
      final dateReservation =
          now.subtract(const Duration(hours: 10)); // Il y a 10h

      final isActive =
          BusinessRules.isReservationActive(dateReservation, 'EN_ATTENTE');

      expect(isActive, true);
    });

    test(
        'isReservationActive doit retourner faux si la réservation a plus de 24h et est EN_ATTENTE',
        () {
      final now = DateTime.now();
      final dateReservation =
          now.subtract(const Duration(hours: 25)); // Il y a 25h

      final isActive =
          BusinessRules.isReservationActive(dateReservation, 'EN_ATTENTE');

      expect(isActive, false);
    });

    test('isReservationActive doit retourner faux si le statut est REFUSER',
        () {
      final now = DateTime.now();
      final dateReservation =
          now.subtract(const Duration(hours: 2)); // Il y a 2h

      final isActive =
          BusinessRules.isReservationActive(dateReservation, 'REFUSER');

      expect(isActive, false);
    });

    test('isReservationActive doit retourner vrai si le statut est CONFIRMER',
        () {
      final now = DateTime.now();
      final dateReservation =
          now.subtract(const Duration(hours: 30)); // Il y a 30h

      final isActive =
          BusinessRules.isReservationActive(dateReservation, 'CONFIRMER');

      expect(isActive, true);
    });

    test('tempsRestantReservation doit calculer correctement le temps restant',
        () {
      final now = DateTime.now();
      final dateReservation =
          now.subtract(const Duration(hours: 22)); // Il y a 22h, reste 2h

      final tempsRestant =
          BusinessRules.tempsRestantReservation(dateReservation);

      // On teste en minutes pour éviter les problèmes de millisecondes
      expect(tempsRestant.inMinutes, closeTo(120, 1));
    });

    test('tempsRestantReservation doit retourner 0 si la durée est expirée',
        () {
      final now = DateTime.now();
      final dateReservation =
          now.subtract(const Duration(hours: 48)); // Il y a 48h

      final tempsRestant =
          BusinessRules.tempsRestantReservation(dateReservation);

      expect(tempsRestant.inSeconds, 0);
    });
  });
}
