/// Point de passage d'une visite virtuelle : posé dans un panorama (source), il mène à un autre (cible).
/// Sa position est une direction dans la sphère, en degrés (azimut, élévation).
class LienPanoramaModel {
  final int id;
  final int sourceId;
  final int cibleId;
  final double azimut;
  final double elevation;
  final String libelle;

  const LienPanoramaModel({
    required this.id,
    required this.sourceId,
    required this.cibleId,
    required this.azimut,
    required this.elevation,
    required this.libelle,
  });

  factory LienPanoramaModel.fromJson(Map<String, dynamic> json) => LienPanoramaModel(
        id: (json['id'] as num).toInt(),
        sourceId: (json['sourceId'] as num).toInt(),
        cibleId: (json['cibleId'] as num).toInt(),
        azimut: (json['azimut'] as num?)?.toDouble() ?? 0,
        elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
        libelle: json['libelle'] as String? ?? 'Pièce suivante',
      );
}
