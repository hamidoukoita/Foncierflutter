import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/geo_distance.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/commodite_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/proximite_commodite_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/domain/lieu_carte.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/domain/lieu_carte_builder.dart';

BienFoncierModel _bien(
        {double? lat,
        double? lng,
        List<CommoditeModel> commodites = const [],
        int? programmeId}) =>
    BienFoncierModel(
      id: 1,
      reference: 'PARC-1',
      superficie: 300,
      prix: 1000000,
      statut: 'DISPONIBLE',
      latitude: lat,
      longitude: lng,
      programmeId: programmeId,
      commodites: commodites,
    );

void main() {
  group('GeoDistance', () {
    test('1 millième de degré de latitude ≈ 111 m', () {
      final d = GeoDistance.metres(12.639, -8.003, 12.640, -8.003);
      expect(d, closeTo(111, 2));
    });

    test('format', () {
      expect(GeoDistance.format(448), '450 m');
      expect(GeoDistance.format(1240), '1,2 km');
    });
  });

  group('LieuCarteBuilder', () {
    test('distance déclarée prioritaire sur le GPS', () {
      final lieu = LieuCarteBuilder.pourBien(
        _bien(lat: 12.639, lng: -8.003),
        proximites: const [
          ProximiteCommoditeModel(
            id: 1,
            distanceKm: 0.3,
            commodite: CommoditeModel(
                id: 7, nom: 'Mosquée', latitude: 12.70, longitude: -8.003),
          ),
        ],
      );
      expect(lieu.commodites.single.distanceMetres, 300);
    });

    test('bien géolocalisé → position exacte, commodités triées par distance',
        () {
      final lieu = LieuCarteBuilder.pourBien(_bien(
        lat: 12.639,
        lng: -8.003,
        commodites: const [
          CommoditeModel(
              id: 1, nom: 'Loin', latitude: 12.65, longitude: -8.003),
          CommoditeModel(id: 2, nom: 'Sans GPS'),
          CommoditeModel(
              id: 3, nom: 'Proche', latitude: 12.640, longitude: -8.003),
        ],
      ));
      expect(lieu.precision, PrecisionPosition.exacte);
      expect(lieu.commodites.map((c) => c.commodite.nom),
          ['Proche', 'Loin', 'Sans GPS']);
      expect(lieu.commodites.last.distanceMetres, isNull);
    });

    test('lot sans GPS → centre des lots de la cité', () {
      final lieu = LieuCarteBuilder.pourBien(
        _bien(programmeId: 9),
        programme: const ProgrammeFoncier(id: 9, nom: 'Cité'),
        lots: const [
          LotProgramme(id: 1, latitude: 12.0, longitude: -8.0),
          LotProgramme(id: 2, latitude: 12.2, longitude: -8.2),
        ],
      );
      expect(lieu.precision, PrecisionPosition.centreDesLots);
      expect(lieu.position!.latitude, closeTo(12.1, 1e-9));
    });

    test('cité sans GPS ni lots → centre de la commune', () {
      final lieu = LieuCarteBuilder.pourProgramme(
        const ProgrammeFoncier(
            id: 1, nom: 'Cité Espoir', lieu: 'Sanankoroba, cercle de Kati'),
      );
      expect(lieu.precision, PrecisionPosition.commune);
    });

    test('aucune information → non localisé, sans crash', () {
      final lieu = LieuCarteBuilder.pourBien(_bien());
      expect(lieu.estLocalise, isFalse);
    });
  });
}
