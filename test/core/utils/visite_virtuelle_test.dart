import 'package:flutter_mobile_prospect_agent/data/models/lien_panorama_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/visite_virtuelle_model.dart';
import 'package:flutter_test/flutter_test.dart';

LienPanoramaModel lien({int id = 1, int source = 10, int cible = 20, double azimut = 0, double? arriveeAz, double? arriveeEl}) =>
    LienPanoramaModel(
      id: id,
      sourceId: source,
      cibleId: cible,
      azimut: azimut,
      elevation: 0,
      libelle: 'Salon',
      azimutArrivee: arriveeAz,
      elevationArrivee: arriveeEl,
    );

MediaModel pano(int id) => MediaModel(id: id, type: 'PANORAMA_360', url: '/uploads/medias/$id.jpg');

void main() {
  group('VisiteVirtuelleModel', () {
    test('lit la pièce de départ et les vues d’arrivée', () {
      final v = VisiteVirtuelleModel.fromJson({
        'panoramaDepartId': 30,
        'liens': [
          {'id': 1, 'sourceId': 10, 'cibleId': 20, 'azimut': 12, 'elevation': -5, 'libelle': 'Salon', 'azimutArrivee': 90, 'elevationArrivee': 0},
        ],
      });
      expect(v.panoramaDepartId, 30);
      expect(v.active, isTrue);
      expect(v.liens.single.azimutArrivee, 90);
    });

    test('commence par la pièce choisie, sinon la première', () {
      final panoramas = [pano(10), pano(20), pano(30)];
      expect(const VisiteVirtuelleModel(panoramaDepartId: 30).indexDepart(panoramas), 2);
      expect(const VisiteVirtuelleModel().indexDepart(panoramas), 0);
      expect(const VisiteVirtuelleModel(panoramaDepartId: 99).indexDepart(panoramas), 0);
    });

    test('utilise la vue d’arrivée réglée par la société', () {
      final aller = lien(arriveeAz: 45, arriveeEl: -5);
      final vue = VisiteVirtuelleModel(liens: [aller]).vueArrivee(aller)!;
      expect(vue.azimut, 45);
      expect(vue.elevation, -5);
    });

    test('se place dos au point retour sans réglage', () {
      final aller = lien();
      final retour = lien(id: 2, source: 20, cible: 10, azimut: 170);
      final vue = VisiteVirtuelleModel(liens: [aller, retour]).vueArrivee(aller)!;
      expect(vue.azimut, -10);
      expect(vue.elevation, 0);
    });

    test('ne propose rien sans réglage ni point retour', () {
      final aller = lien();
      expect(VisiteVirtuelleModel(liens: [aller]).vueArrivee(aller), isNull);
    });

    test('nomme une pièce sans titre selon son rang, et une porte sans libellé selon sa pièce', () {
      final panoramas = [pano(10), const MediaModel(id: 20, type: 'PANORAMA_360', url: '/u/20.jpg', titre: 'Salon')];
      expect(VisiteVirtuelleModel.nomPiece(panoramas, 10), 'Pièce 1');
      expect(VisiteVirtuelleModel.nomPiece(panoramas, 20), 'Salon');
      const sansLibelle = LienPanoramaModel(id: 2, sourceId: 20, cibleId: 10, azimut: 0, elevation: 0);
      expect(VisiteVirtuelleModel.libellePorte(sansLibelle, panoramas), 'Pièce 1');
      const nommee = LienPanoramaModel(id: 3, sourceId: 10, cibleId: 20, azimut: 0, elevation: 0, libelle: 'Vers le jardin');
      expect(VisiteVirtuelleModel.libellePorte(nommee, panoramas), 'Vers le jardin');
    });
  });
}
