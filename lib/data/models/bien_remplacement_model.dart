/// Bien disponible de la même société, proposé pour reporter une réservation
/// dont le bien a été vendu à un autre acquéreur — miroir de `BienRemplacementResponse`.
class BienRemplacementModel {
  final int id;

  /// LOT_PROGRAMME, PARCELLE_INDIVIDUELLE ou MAISON_CLE_EN_MAIN.
  final String typeBien;
  final String designation;
  final String? programmeNom;
  final double? superficie;
  final double prix;
  final String? imageUrl;

  const BienRemplacementModel({
    required this.id,
    required this.typeBien,
    required this.designation,
    required this.prix,
    this.programmeNom,
    this.superficie,
    this.imageUrl,
  });

  String get libelleType => switch (typeBien) {
        'LOT_PROGRAMME' => 'Lot',
        'PARCELLE_INDIVIDUELLE' => 'Parcelle',
        'MAISON_CLE_EN_MAIN' => 'Maison clé en main',
        _ => 'Bien',
      };

  factory BienRemplacementModel.fromJson(Map<String, dynamic> json) {
    return BienRemplacementModel(
      id: (json['id'] as num).toInt(),
      typeBien: json['typeBien'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      programmeNom: json['programmeNom'] as String?,
      superficie: (json['superficie'] as num?)?.toDouble(),
      prix: (json['prix'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
