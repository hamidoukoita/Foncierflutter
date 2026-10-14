import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/domain/modele_maison.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/domain/projet_construction.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/domain/soumission_projet.dart';

void main() {
  group('ModeleMaison.convientA', () {
    const modele = ModeleMaison(
      id: 1,
      libelle: 'Villa F4',
      surfaceTerrainMin: 300,
      surfaceTerrainMax: 500,
      typeTerrainCompatible: 'STANDARD',
    );

    test('accepte un terrain dans la plage et de forme compatible', () {
      expect(modele.convientA(400, 'STANDARD'), isTrue);
      expect(modele.convientA(400, null), isTrue);
    });

    test('refuse un terrain trop petit, trop grand ou de forme différente', () {
      expect(modele.convientA(250, null), isFalse);
      expect(modele.convientA(600, null), isFalse);
      expect(modele.convientA(400, 'ANGLE'), isFalse);
    });
  });

  group('SoumissionProjet.toJson', () {
    test('modèle du catalogue : pas de champs de modèle personnalisé', () {
      final json = const SoumissionProjet(
        societeId: 3,
        modeleId: 7,
        numeroTitreFoncier: 'TF 12',
        superficieTerrain: 400,
        descriptionModelePersonnalise: 'ignorée',
        nombreChambres: 4,
      ).toJson();
      expect(json['modelMaisonId'], 7);
      expect(json.containsKey('descriptionModelePersonnalise'), isFalse);
      expect(json.containsKey('nombreChambresSouhaitees'), isFalse);
    });

    test('modèle personnalisé : description et pièces souhaitées envoyées', () {
      final json = const SoumissionProjet(
        societeId: 3,
        numeroTitreFoncier: 'TF 12',
        superficieTerrain: 400,
        descriptionModelePersonnalise: 'Villa R+1 avec terrasse',
        nombreChambres: 4,
      ).toJson();
      expect(json.containsKey('modelMaisonId'), isFalse);
      expect(json['descriptionModelePersonnalise'], 'Villa R+1 avec terrasse');
      expect(json['nombreChambresSouhaitees'], 4);
    });
  });

  test('ProjetConstruction lit le statut et le modèle personnalisé', () {
    final p = ProjetConstruction.fromJson({
      'id': 5,
      'numeroDossier': 'PRJ-1',
      'statut': 'ACCEPTER',
      'progression': 40,
      'numeroTitreFoncier': 'TF 12',
      'superficieTerrain': 400,
      'modelePersonnalise': true,
      'fichiers': [
        {'id': 1, 'type': 'TITRE_FONCIER', 'nomOriginal': 'tf.pdf'}
      ],
    });
    expect(p.statut, StatutProjet.accepte);
    expect(p.libelleModele, 'Modèle personnalisé');
    expect(p.fichiers.single.type, TypeFichierProjet.titreFoncier);
  });
}
