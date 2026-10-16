import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/agent_planning.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/reservation_suivi.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/visite_statut.dart';

RendezVousModel _rdv(int id, DateTime date,
        {String statut = 'ACCEPTER', String? compteRendu}) =>
    RendezVousModel(
      id: id,
      dateRendezVous: date,
      typeRDV: 'CHANTIER',
      statut: statut,
      compteRendu: compteRendu,
    );

void main() {
  final now = DateTime.now();
  final dans2h = now.add(const Duration(hours: 2));
  final demain = now.add(const Duration(days: 1));
  final hier = now.subtract(const Duration(days: 1));

  group('Statut de visite', () {
    test('EN_ATTENTE → à reconfirmer', () {
      expect(_rdv(1, dans2h, statut: 'EN_ATTENTE').statutVisite(now),
          VisiteStatut.aReconfirmer);
    });

    test('acceptée et passée → effectuée', () {
      expect(_rdv(1, hier).statutVisite(now), VisiteStatut.effectuee);
    });

    test('acceptée avec compte-rendu → effectuée', () {
      expect(_rdv(1, dans2h, compteRendu: 'RAS').statutVisite(now),
          VisiteStatut.effectuee);
    });

    test('heure de créneau prioritaire sur la date du RDV', () {
      final rdv = RendezVousModel(
        id: 1,
        dateRendezVous: DateTime(2026, 10, 24, 8),
        typeRDV: 'SIEGE',
        statut: 'ACCEPTER',
        creneauHeureDebut: '10:30:00',
        creneauHeureFin: '11:30',
      );
      expect(rdv.debut, DateTime(2026, 10, 24, 10, 30));
      expect(rdv.fin, DateTime(2026, 10, 24, 11, 30));
    });
  });

  group('AgentPlanning', () {
    final visites = [
      _rdv(1, demain),
      _rdv(2, dans2h),
      _rdv(3, hier),
      _rdv(4, demain, statut: 'REFUSER'),
    ];

    test('prochaine visite = la plus proche à mener', () {
      expect(AgentPlanning.prochaine(visites, now)?.id, 2);
    });

    test('à venir exclut aujourd\'hui, refusées et effectuées', () {
      expect(AgentPlanning.aVenir(visites, now).map((v) => v.id), [1]);
    });

    test('effectuées', () {
      expect(AgentPlanning.effectuees(visites, now).map((v) => v.id), [3]);
    });
  });

  group('Suivi des réservations', () {
    ReservationModel res(int id, String statut, DateTime date, {DateTime? expiration}) =>
        ReservationModel(
          id: id,
          numeroDossier: 'D$id',
          dateReservation: date,
          dateDebutDecompte: expiration?.subtract(const Duration(hours: 72)),
          dateExpiration: expiration,
          statut: statut,
        );

    test('tri : à démarrer, puis décomptes (échéance proche d’abord), puis terminées', () {
      final liste = [
        res(1, 'VENDUE', hier),
        res(2, 'EN_COURS', hier, expiration: dans2h.add(const Duration(days: 1))),
        res(3, 'EN_ATTENTE', hier),
        res(4, 'EN_COURS', hier, expiration: dans2h),
        res(5, 'ANNULEE', hier),
      ];
      expect(ReservationsSuivi.trier(liste).map((r) => r.id).take(3), [3, 4, 2]);
      expect(ReservationsSuivi.dossiersEnCours(liste), 3);
    });

    test('anciens dossiers : confirmé = en cours, refusé = annulé', () {
      expect(res(1, 'CONFIRMER', hier).isEnCours, isTrue);
      expect(res(2, 'REFUSER', hier).isAnnulee, isTrue);
    });

    test('vente possible seulement avant l’échéance', () {
      expect(res(1, 'EN_COURS', hier, expiration: dans2h).peutConclure(now), isTrue);
      expect(res(2, 'EN_COURS', hier, expiration: hier).peutConclure(now), isFalse);
    });
  });
}
