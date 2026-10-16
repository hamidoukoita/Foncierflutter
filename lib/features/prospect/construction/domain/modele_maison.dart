/// Modèle de maison du catalogue d'une société.
class ModeleMaison {
  final int id;
  final String libelle;
  final String? description;
  final String? imageUrl;
  /// Panoramas 360° de la galerie du modèle.
  final int nombrePanoramas;
  final double? surfaceTerrainMin;
  final double? surfaceTerrainMax;
  final double? surfaceConstruite;
  final int? nombreChambres;
  final int? nombreSallesBain;
  final String? typeTerrainCompatible;

  const ModeleMaison({
    required this.id,
    required this.libelle,
    this.description,
    this.imageUrl,
    this.nombrePanoramas = 0,
    this.surfaceTerrainMin,
    this.surfaceTerrainMax,
    this.surfaceConstruite,
    this.nombreChambres,
    this.nombreSallesBain,
    this.typeTerrainCompatible,
  });

  /// Le modèle convient-il au terrain ? Mêmes règles que le backend (surface et forme).
  bool convientA(double? superficie, String? typeTerrain) {
    if (superficie != null) {
      if (surfaceTerrainMin != null && superficie < surfaceTerrainMin!) return false;
      if (surfaceTerrainMax != null && superficie > surfaceTerrainMax!) return false;
    }
    if (typeTerrain != null && (typeTerrainCompatible ?? '').isNotEmpty) {
      return typeTerrainCompatible!.toUpperCase() == typeTerrain.toUpperCase();
    }
    return true;
  }

  /// « 300 à 500 m² de terrain », « dès 250 m² »…
  String? get terrainRequis {
    String n(double v) => v.toStringAsFixed(0);
    if (surfaceTerrainMin != null && surfaceTerrainMax != null) {
      return '${n(surfaceTerrainMin!)} à ${n(surfaceTerrainMax!)} m² de terrain';
    }
    if (surfaceTerrainMin != null) return 'Terrain dès ${n(surfaceTerrainMin!)} m²';
    if (surfaceTerrainMax != null) return 'Terrain jusqu’à ${n(surfaceTerrainMax!)} m²';
    return null;
  }

  factory ModeleMaison.fromJson(Map<String, dynamic> json) {
    double? d(String k) => (json[k] as num?)?.toDouble();
    int? i(String k) => (json[k] as num?)?.toInt();
    return ModeleMaison(
      id: (json['id'] as num).toInt(),
      libelle: json['libeller'] as String? ?? 'Modèle',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      nombrePanoramas: i('nombrePanoramas') ?? 0,
      surfaceTerrainMin: d('surfaceTerrainMin'),
      surfaceTerrainMax: d('surfaceTerrainMax'),
      surfaceConstruite: d('surfaceConstruite'),
      nombreChambres: i('nombreChambres'),
      nombreSallesBain: i('nombreSallesBain'),
      typeTerrainCompatible: json['typeTerrainCompatible'] as String?,
    );
  }
}
