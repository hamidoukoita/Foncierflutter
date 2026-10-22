import 'package:flutter_mobile_prospect_agent/core/utils/panorama_geometrie.dart';
import 'package:flutter_mobile_prospect_agent/data/models/lien_panorama_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';

/// Visite virtuelle d'une maison clé en main : pièce de départ et points de passage entre ses panoramas.
class VisiteVirtuelleModel {
  /// Panorama par lequel commence la visite ; null : le premier de la galerie.
  final int? panoramaDepartId;
  final List<LienPanoramaModel> liens;

  const VisiteVirtuelleModel({this.panoramaDepartId, this.liens = const []});

  static const vide = VisiteVirtuelleModel();

  /// Sans point de passage, les panoramas se parcourent librement comme une galerie.
  bool get active => liens.isNotEmpty;

  factory VisiteVirtuelleModel.fromJson(Map<String, dynamic> json) =>
      VisiteVirtuelleModel(
        panoramaDepartId: (json['panoramaDepartId'] as num?)?.toInt(),
        liens: ((json['liens'] as List<dynamic>?) ?? [])
            .map((e) => LienPanoramaModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Index de la pièce de départ dans [panoramas] : celle choisie par la société, sinon la première.
  int indexDepart(List<MediaModel> panoramas) {
    final i = panoramaDepartId == null
        ? -1
        : panoramas.indexWhere((p) => p.id == panoramaDepartId);
    return i >= 0 ? i : 0;
  }

  /// Nom d'une pièce : le titre du panorama, sinon « Pièce N » selon l'ordre de la galerie.
  static String nomPiece(List<MediaModel> panoramas, int panoramaId) {
    final i = panoramas.indexWhere((p) => p.id == panoramaId);
    final titre = i < 0 ? null : panoramas[i].titre?.trim();
    if (titre != null && titre.isNotEmpty) return titre;
    return i < 0 ? 'Pièce' : 'Pièce ${i + 1}';
  }

  /// Texte d'une porte : son libellé, sinon le nom de la pièce où elle mène.
  static String libellePorte(
      LienPanoramaModel lien, List<MediaModel> panoramas) {
    final libelle = lien.libelle?.trim();
    return libelle != null && libelle.isNotEmpty
        ? libelle
        : nomPiece(panoramas, lien.cibleId);
  }

  /// Points de passage posés dans ce panorama.
  List<LienPanoramaModel> pointsDe(int panoramaId) =>
      liens.where((l) => l.sourceId == panoramaId).toList();

  /// Direction regardée en arrivant par [lien] : la vue réglée par la société, sinon dos à la porte
  /// du point retour ; null à défaut.
  DirectionPanorama? vueArrivee(LienPanoramaModel lien) {
    if (lien.azimutArrivee != null && lien.elevationArrivee != null) {
      return DirectionPanorama(lien.azimutArrivee!, lien.elevationArrivee!);
    }
    for (final retour in liens) {
      if (retour.sourceId == lien.cibleId && retour.cibleId == lien.sourceId) {
        return DirectionPanorama(
            PanoramaGeometrie.normaliserAzimut(retour.azimut + 180), 0);
      }
    }
    return null;
  }
}
