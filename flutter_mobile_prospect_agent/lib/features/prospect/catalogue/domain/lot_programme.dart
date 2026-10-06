class LotProgramme {
  final int id;
  final String numeroLot;
  final double? superficie;
  final double? prix;
  final String? statut;
  final int? programmeId;

  const LotProgramme({
    required this.id,
    required this.numeroLot,
    this.superficie,
    this.prix,
    this.statut,
    this.programmeId,
  });

  factory LotProgramme.fromJson(Map<String, dynamic> json) {
    return LotProgramme(
      id: (json['id'] as num?)?.toInt() ?? 0,
      numeroLot: json['numeroLot'] as String? ?? '',
      superficie: (json['superficie'] as num?)?.toDouble(),
      prix: (json['prix'] as num?)?.toDouble(),
      statut: json['statut'] as String?,
      programmeId: (json['programmeId'] as num?)?.toInt(),
    );
  }
}
