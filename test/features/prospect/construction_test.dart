import 'package:flutter_mobile_prospect_agent/features/prospect/construction/domain/description_maison.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/domain/echange_projet.dart';
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

  group('ModeleMaison.fromJson', () {
    test('lit la couverture et le nombre de panoramas 360°', () {
      final m = ModeleMaison.fromJson({
        'id': 4,
        'libeller': 'Villa Kayes',
        'imageUrl': '/uploads/medias/a.jpg',
        'nombrePanoramas': 2,
      });
      expect(m.libelle, 'Villa Kayes');
      expect(m.imageUrl, '/uploads/medias/a.jpg');
      expect(m.nombrePanoramas, 2);
    });

    test('sans galerie : aucun panorama', () {
      expect(ModeleMaison.fromJson({'id': 1}).nombrePanoramas, 0);
    });
  });

  group('SoumissionProjet.toJson', () {
    test('modèle du catalogue : pas de champs de modèle personnalisé', () {
      final json = const SoumissionProjet(
        societeId: 3,
        modeleId: 7,
        numeroTitreFoncier: 'TF 12',
        superficieTerrain: 400,
        maisonSouhaitee: DescriptionMaison(nombreChambres: 4),
      ).toJson();
      expect(json['modelMaisonId'], 7);
      expect(json.containsKey('maisonSouhaitee'), isFalse);
    });

    test('modèle personnalisé : questionnaire envoyé, sans surface', () {
      final json = const SoumissionProjet(
        societeId: 3,
        numeroTitreFoncier: 'TF-12',
        superficieTerrain: 400,
        maisonSouhaitee: DescriptionMaison(
          nombreNiveaux: 2,
          nombreChambres: 4,
          cuisine: TypeCuisine.lesDeux,
          equipements: {EquipementMaison.forage},
          precisions: 'Grande cour',
        ),
      ).toJson();
      expect(json.containsKey('modelMaisonId'), isFalse);
      final maison = json['maisonSouhaitee'] as Map<String, dynamic>;
      expect(maison['nombreNiveaux'], 2);
      expect(maison['nombreChambres'], 4);
      expect(maison['cuisine'], 'LES_DEUX');
      expect(maison['equipements'], ['FORAGE']);
      expect(maison['precisions'], 'Grande cour');
      expect(maison.containsKey('surfaceHabitable'), isFalse);
    });
  });

  group('DescriptionMaison', () {
    test('les chambres avec salle de bain ne dépassent pas le nombre de chambres', () {
      final d = const DescriptionMaison(nombreChambres: 3, nombreSuites: 3).copyWith(nombreChambres: 2);
      expect(d.nombreSuites, 2);
    });

    test('résume les souhaits lisiblement', () {
      const d = DescriptionMaison(
        nombreNiveaux: 2,
        style: StyleMaison.moderne,
        nombreChambres: 4,
        nombreSuites: 2,
        placesGarage: 1,
        equipements: {EquipementMaison.terrasse},
      );
      expect(d.caracteristiques, [
        'R+1 · Moderne',
        '4 chambres dont 2 avec salle de bain',
        'Garage 1 véhicule',
        'Terrasse',
      ]);
    });

    test('relit la réponse du serveur', () {
      final d = DescriptionMaison.fromJson({
        'nombreNiveaux': 1,
        'cuisine': 'EXTERIEURE',
        'equipements': ['COUR', 'INCONNU'],
        'surfaceHabitable': 120,
      });
      expect(d.cuisine, TypeCuisine.exterieure);
      expect(d.equipements, {EquipementMaison.cour});
      expect(d.surfaceHabitable, 120);
    });
  });

  group('Fil d’échange', () {
    test('lit messages et propositions', () {
      final fil = [
        {
          'type': 'MESSAGE',
          'message': {'id': 1, 'texte': 'Bonjour', 'cote': 'SOCIETE', 'dateEnvoi': '2026-10-23T10:00:00'},
        },
        {
          'type': 'PROPOSITION',
          'proposition': {
            'id': 2,
            'numero': 1,
            'titre': 'Villa R+1',
            'statut': 'EN_ATTENTE',
            'prixEstime': 32000000,
            'maison': {'nombreChambres': 4},
            'plans': [],
          },
        },
        {'type': 'INCONNU'},
      ].map(ElementFil.fromJson).whereType<ElementFil>().toList();
      expect(fil, hasLength(2));
      expect((fil.first as MessageFil).message.cote, CoteEchange.societe);
      final p = (fil.last as PropositionFil).proposition;
      expect(p.enAttente, isTrue);
      expect(p.maison?.nombreChambres, 4);
    });
  });

  test('ProjetConstruction lit le statut et le modèle personnalisé', () {
    final p = ProjetConstruction.fromJson({
      'id': 5,
      'numeroDossier': 'PRJ-1',
      'statut': 'EN_DISCUSSION',
      'progression': 40,
      'numeroTitreFoncier': 'TF 12',
      'superficieTerrain': 400,
      'modelePersonnalise': true,
      'fichiers': [
        {'id': 1, 'type': 'TITRE_FONCIER', 'nomOriginal': 'tf.pdf'}
      ],
    });
    expect(p.statut, StatutProjet.enDiscussion);
    expect(p.enCours, isTrue);
    expect(p.libelleModele, 'Modèle personnalisé');
    expect(p.fichiers.single.type, TypeFichierProjet.titreFoncier);
  });
}
