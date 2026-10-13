import 'package:latlong2/latlong.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/geo_distance.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/commodite_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/proximite_commodite_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'communes_reference.dart';
import 'lieu_carte.dart';

/// Construit un [LieuCarte] en appliquant les replis de position :
/// bien → cité → centre des lots → commune → non localisé.
class LieuCarteBuilder {
  LieuCarteBuilder._();

  static LieuCarte pourBien(
    BienFoncierModel bien, {
    ProgrammeFoncier? programme,
    List<LotProgramme> lots = const [],
    List<ProximiteCommoditeModel> proximites = const [],
    List<String> equipementsInternes = const [],
  }) {
    final (position, precision) = bien.aDesCoordonnees
        ? (LatLng(bien.latitude!, bien.longitude!), PrecisionPosition.exacte)
        : _positionCite(programme, lots,
            libelleSecours: bien.localisation ?? bien.programmeNom);

    return LieuCarte(
      titre: bien.designation,
      sousTitre:
          _joindre([bien.programmeNom, bien.localisation, bien.societeNom]),
      position: position,
      precision: precision,
      commodites: _proches(proximites, bien.commodites, position),
      equipementsSurSite: _equipements(
        eau: bien.eauSomapep,
        electricite: bien.electriciteEdm,
        voirie: bien.voieBitumee,
        cloture: bien.murCloture,
      ),
      equipementsInternes: equipementsInternes,
    );
  }

  static LieuCarte pourProgramme(
    ProgrammeFoncier programme, {
    List<LotProgramme> lots = const [],
    List<ProximiteCommoditeModel> proximites = const [],
    List<String> equipementsInternes = const [],
  }) {
    final (position, precision) = _positionCite(programme, lots);
    return LieuCarte(
      titre: programme.nom,
      sousTitre: _joindre([programme.lieu, programme.societeNom]),
      position: position,
      precision: precision,
      commodites: _proches(proximites, const [], position),
      equipementsSurSite: _equipements(
        eau: programme.eauSomapep,
        electricite: programme.electriciteEdm,
        voirie: programme.voirieBitumee,
      ),
      equipementsInternes: equipementsInternes,
    );
  }

  /// Équipements internes dessinés dans le plan de masse (hors voirie et espaces verts).
  static List<String> equipementsDuPlan(PlanMasse? plan) {
    if (plan == null) return const [];
    return plan.elements
        .where((e) => e.visible && !e.isRoute && e.type != 'ESPACE_VERT')
        .map((e) => e.affichage)
        .toSet()
        .toList();
  }

  static (LatLng?, PrecisionPosition?) _positionCite(
    ProgrammeFoncier? programme,
    List<LotProgramme> lots, {
    String? libelleSecours,
  }) {
    if (programme != null && programme.aDesCoordonnees) {
      return (
        LatLng(programme.latitude!, programme.longitude!),
        PrecisionPosition.exacte
      );
    }
    final centre = _centreDesLots(lots);
    if (centre != null) return (centre, PrecisionPosition.centreDesLots);

    final commune = CommunesReference.depuisLibelle(programme?.lieu) ??
        CommunesReference.depuisLibelle(libelleSecours);
    if (commune != null) return (commune, PrecisionPosition.commune);
    return (null, null);
  }

  static LatLng? _centreDesLots(List<LotProgramme> lots) {
    final points = lots
        .where((l) => l.latitude != null && l.longitude != null)
        .map((l) => LatLng(l.latitude!, l.longitude!))
        .toList();
    if (points.isEmpty) return null;
    final lat = points.map((p) => p.latitude).reduce((a, b) => a + b);
    final lng = points.map((p) => p.longitude).reduce((a, b) => a + b);
    return LatLng(lat / points.length, lng / points.length);
  }

  /// Distance déclarée par la société en priorité, sinon calculée depuis le GPS.
  /// Tri : les plus proches d'abord, les distances inconnues en fin de liste.
  static List<CommoditeProche> _proches(
    List<ProximiteCommoditeModel> proximites,
    List<CommoditeModel> commoditesAssociees,
    LatLng? origine,
  ) {
    final vues = <int>{};
    final liste = <CommoditeProche>[];
    for (final p in proximites) {
      if (!vues.add(p.commodite.id)) continue;
      final declaree = p.distanceKm != null ? p.distanceKm! * 1000 : null;
      liste.add(CommoditeProche(
          p.commodite, declaree ?? _distanceGps(p.commodite, origine)));
    }
    for (final c in commoditesAssociees) {
      if (vues.add(c.id)) {
        liste.add(CommoditeProche(c, _distanceGps(c, origine)));
      }
    }
    liste.sort((a, b) {
      if (a.distanceMetres == null) return b.distanceMetres == null ? 0 : 1;
      if (b.distanceMetres == null) return -1;
      return a.distanceMetres!.compareTo(b.distanceMetres!);
    });
    return liste;
  }

  static double? _distanceGps(CommoditeModel c, LatLng? origine) {
    if (origine == null || !c.estGeolocalisee) return null;
    return GeoDistance.metres(
        origine.latitude, origine.longitude, c.latitude!, c.longitude!);
  }

  static List<String> _equipements({
    bool? eau,
    bool? electricite,
    bool? voirie,
    bool? cloture,
  }) =>
      [
        if (eau == true) 'Eau SOMAPEP',
        if (electricite == true) 'Électricité EDM',
        if (voirie == true) 'Voie bitumée',
        if (cloture == true) 'Clôture',
      ];

  static String? _joindre(List<String?> elements) {
    final texte = elements
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .join(' • ');
    return texte.isEmpty ? null : texte;
  }
}
