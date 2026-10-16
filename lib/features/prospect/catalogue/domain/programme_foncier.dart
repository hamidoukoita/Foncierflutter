class ProgrammeFoncier {
  final int id;
  final String nom;
  final String? description;
  final String? lieu;
  final double? latitude;
  final double? longitude;

  /// Photo de couverture (chemin relatif servi par le backend), null sans photo.
  final String? imageUrl;

  /// Nombre de panoramas 360° de la cité.
  final int nombrePanoramas;
  final String? numeroTitreMere;
  final double? superficieTotale;
  final String? statut;
  final int? avancement;
  final bool? eauSomapep;
  final bool? electriciteEdm;
  final bool? voirieBitumee;
  final int? societeId;
  final String? societeNom;
  /// Logo de la société promotrice (chemin relatif servi par le backend).
  final String? societeLogoUrl;
  final int? totalLots;
  final int? planMasseId;

  const ProgrammeFoncier({
    required this.id,
    required this.nom,
    this.description,
    this.lieu,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.nombrePanoramas = 0,
    this.numeroTitreMere,
    this.superficieTotale,
    this.statut,
    this.avancement,
    this.eauSomapep,
    this.electriciteEdm,
    this.voirieBitumee,
    this.societeId,
    this.societeNom,
    this.societeLogoUrl,
    this.totalLots,
    this.planMasseId,
  });

  String get localisation => lieu ?? '';

  bool get aDesCoordonnees => latitude != null && longitude != null;

  factory ProgrammeFoncier.fromJson(Map<String, dynamic> json) {
    return ProgrammeFoncier(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      lieu: json['lieu'] as String? ?? json['localisation'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      nombrePanoramas: (json['nombrePanoramas'] as num?)?.toInt() ?? 0,
      numeroTitreMere: json['numeroTitreMere'] as String?,
      superficieTotale: (json['superficieTotale'] as num?)?.toDouble(),
      statut: json['statut']?.toString(),
      avancement: (json['avancement'] as num?)?.toInt(),
      eauSomapep: json['eauSomapep'] as bool?,
      electriciteEdm: json['electriciteEdm'] as bool?,
      voirieBitumee: json['voirieBitumee'] as bool?,
      societeId: (json['societeId'] as num?)?.toInt(),
      societeNom: json['societeNom'] as String?,
      societeLogoUrl: json['societeLogoUrl'] as String?,
      totalLots: (json['totalLots'] as num?)?.toInt() ??
          (json['lotsTotal'] as num?)?.toInt(),
      planMasseId: (json['planMasseId'] as num?)?.toInt(),
    );
  }
}
