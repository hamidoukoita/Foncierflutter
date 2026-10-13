import 'package:latlong2/latlong.dart';
import 'package:flutter_mobile_prospect_agent/data/models/commodite_model.dart';

/// Origine de la position affichée (du plus au moins précis).
enum PrecisionPosition {
  /// Coordonnées GPS du bien ou de la cité.
  exacte,

  /// Centre géographique des lots géolocalisés de la cité.
  centreDesLots,

  /// Centre approximatif de la commune / du quartier.
  commune,
}

/// Commodité accompagnée de sa distance au bien (si calculable).
class CommoditeProche {
  final CommoditeModel commodite;
  final double? distanceMetres;

  const CommoditeProche(this.commodite, this.distanceMetres);
}

/// Tout ce qu'il faut pour afficher la carte d'un bien ou d'une cité.
class LieuCarte {
  final String titre;
  final String? sousTitre;
  final LatLng? position;
  final PrecisionPosition? precision;
  final List<CommoditeProche> commodites;

  /// Viabilisation sur site (VRD) : « Eau SOMAPEP », « EDM »…
  final List<String> equipementsSurSite;

  /// Équipements dessinés dans le plan de masse de la cité (école, mosquée…).
  final List<String> equipementsInternes;

  const LieuCarte({
    required this.titre,
    this.sousTitre,
    this.position,
    this.precision,
    this.commodites = const [],
    this.equipementsSurSite = const [],
    this.equipementsInternes = const [],
  });

  bool get estLocalise => position != null;
}
