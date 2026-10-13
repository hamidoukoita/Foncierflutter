import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/domain/suivi_acquereur.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/zones_exploration.dart';

void main() {
  group('ZonesExploration', () {
    test('le quartier prime sur « Bamako », les précisions entre parenthèses sont ignorées', () {
      expect(ZonesExploration.zoneDe('Bamako, Banankabougou'), 'Banankabougou');
      expect(ZonesExploration.zoneDe('Yirimadio, Bamako'), 'Yirimadio');
      expect(ZonesExploration.zoneDe('Kati (Goudron 200m)'), 'Kati');
      expect(ZonesExploration.zoneDe(null), isNull);
    });

    test('regroupe et trie par nombre de cités', () {
      final zones = ZonesExploration.depuisProgrammes(const [
        ProgrammeFoncier(id: 1, nom: 'A', lieu: 'Kati'),
        ProgrammeFoncier(id: 2, nom: 'B', lieu: 'Bamako, Yirimadio'),
        ProgrammeFoncier(id: 3, nom: 'C', lieu: 'Kati (Goudron 200m)'),
      ]);
      expect(zones.map((z) => (z.nom, z.nombreCites)), [('Kati', 2), ('Yirimadio', 1)]);
    });
  });

  group('SuiviAcquereur', () {
    final now = DateTime(2026, 10, 13, 9);

    ReservationModel res(String statut, DateTime expiration) => ReservationModel(
          id: 1,
          numeroDossier: 'D1',
          dateReservation: expiration.subtract(const Duration(hours: 24)),
          dateExpiration: expiration,
          statut: statut,
        );

    RendezVousModel rdv(int id, DateTime date, String statut) =>
        RendezVousModel(id: id, dateRendezVous: date, typeRDV: 'CHANTIER', statut: statut);

    test('réservation expirée et visite refusée ne remontent pas', () {
      final suivi = SuiviAcquereur.depuis(
        [res('EN_ATTENTE', now.subtract(const Duration(hours: 1)))],
        [rdv(1, now.add(const Duration(days: 1)), 'REFUSER')],
        now,
      );
      expect(suivi.estVide, isTrue);
    });

    test('prochaine visite = la plus proche à venir', () {
      final suivi = SuiviAcquereur.depuis(
        [res('EN_ATTENTE', now.add(const Duration(hours: 5)))],
        [
          rdv(1, now.add(const Duration(days: 3)), 'ACCEPTER'),
          rdv(2, now.add(const Duration(days: 1)), 'EN_ATTENTE'),
        ],
        now,
      );
      expect(suivi.reservationEnCours, isNotNull);
      expect(suivi.prochaineVisite?.id, 2);
    });
  });
}
