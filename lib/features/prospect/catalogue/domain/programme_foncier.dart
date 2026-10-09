class ProgrammeFoncier {
  final int id;
  final String nom;
  final String? description;
  final String? lieu;
  final String? numeroTitreMere;
  final double? superficieTotale;
  final String? statut;
  final int? avancement;
  final bool? eauSomapep;
  final bool? electriciteEdm;
  final bool? voirieBitumee;
  final int? societeId;
  final String? societeNom;
  final int? totalLots;
  final int? planMasseId;

  const ProgrammeFoncier({
    required this.id,
    required this.nom,
    this.description,
    this.lieu,
    this.numeroTitreMere,
    this.superficieTotale,
    this.statut,
    this.avancement,
    this.eauSomapep,
    this.electriciteEdm,
    this.voirieBitumee,
    this.societeId,
    this.societeNom,
    this.totalLots,
    this.planMasseId,
  });

  String get localisation => lieu ?? '';

  factory ProgrammeFoncier.fromJson(Map<String, dynamic> json) {
    return ProgrammeFoncier(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      lieu: json['lieu'] as String? ?? json['localisation'] as String?,
      numeroTitreMere: json['numeroTitreMere'] as String?,
      superficieTotale: (json['superficieTotale'] as num?)?.toDouble(),
      statut: json['statut']?.toString(),
      avancement: (json['avancement'] as num?)?.toInt(),
      eauSomapep: json['eauSomapep'] as bool?,
      electriciteEdm: json['electriciteEdm'] as bool?,
      voirieBitumee: json['voirieBitumee'] as bool?,
      societeId: (json['societeId'] as num?)?.toInt(),
      societeNom: json['societeNom'] as String?,
      totalLots: (json['totalLots'] as num?)?.toInt() ??
          (json['lotsTotal'] as num?)?.toInt(),
      planMasseId: (json['planMasseId'] as num?)?.toInt(),
    );
  }
}
