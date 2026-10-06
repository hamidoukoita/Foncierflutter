class ProgrammeFoncier {
  final int id;
  final String nom;
  final String? localisation;
  final String? statut;
  final double? superficieTotale;
  final int? lotsTotal;
  final int? lotsDisponibles;

  const ProgrammeFoncier({
    required this.id,
    required this.nom,
    this.localisation,
    this.statut,
    this.superficieTotale,
    this.lotsTotal,
    this.lotsDisponibles,
  });

  factory ProgrammeFoncier.fromJson(Map<String, dynamic> json) {
    return ProgrammeFoncier(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      localisation: json['localisation'] as String? ?? json['adresse'] as String?,
      statut: json['statut'] as String?,
      superficieTotale: (json['superficieTotale'] as num?)?.toDouble(),
      lotsTotal: (json['lotsTotal'] as num?)?.toInt(),
      lotsDisponibles: (json['lotsDisponibles'] as num?)?.toInt(),
    );
  }
}
