import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/domain/maison_cle_en_main.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/domain/soumission_projet.dart';

MaisonCleEnMain _maison({String statut = 'DISPONIBLE', bool multiple = false, int? niveaux}) => MaisonCleEnMain(
      id: 1,
      reference: 'MCM-1',
      titre: 'Villa F5',
      prix: 85000000,
      superficie: 400,
      statut: statut,
      reservationMultiple: multiple,
      nombreNiveaux: niveaux,
    );

void main() {
  test('une maison se réserve comme les autres biens', () {
    expect(_maison().peutEtreReserve, isTrue);
    expect(_maison(statut: 'RESERVER').peutEtreReserve, isFalse);
    expect(_maison(statut: 'RESERVER', multiple: true).peutEtreReserve, isTrue);
    expect(_maison(statut: 'VENDUE', multiple: true).peutEtreReserve, isFalse);
  });

  test('libellé des niveaux', () {
    expect(_maison(niveaux: 1).niveaux, 'Plain-pied');
    expect(_maison(niveaux: 2).niveaux, 'R+1');
    expect(_maison().niveaux, isNull);
  });

  test('lit la réponse de l’API', () {
    final m = MaisonCleEnMain.fromJson({
      'id': 9,
      'reference': 'MCM-9',
      'titre': 'Villa Sotuba',
      'prix': 120000000,
      'superficie': 500,
      'statut': 'DISPONIBLE',
      'nombrePanoramas': 2,
      'equipements': ['Garage', 'Jardin'],
    });
    expect(m.nombrePanoramas, 2);
    expect(m.equipements, ['Garage', 'Jardin']);
  });

  test('un projet avec une maison de référence n’envoie pas de modèle personnalisé', () {
    final json = const SoumissionProjet(
      societeId: 2,
      maisonId: 9,
      numeroTitreFoncier: 'TF 1',
      superficieTerrain: 450,
      descriptionModelePersonnalise: 'ignorée',
    ).toJson();
    expect(json['maisonCleEnMainId'], 9);
    expect(json.containsKey('descriptionModelePersonnalise'), isFalse);
  });
}
