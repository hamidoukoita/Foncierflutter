import 'package:equatable/equatable.dart';

/// Commodité de proximité (école, santé, marché…) — miroir de `CommoditerResponse`.
class CommoditeModel extends Equatable {
  final int id;
  final String nom;
  final String? icone;
  final String? description;
  final String? typeLibelle;
  final double? latitude;
  final double? longitude;

  const CommoditeModel({
    required this.id,
    required this.nom,
    this.icone,
    this.description,
    this.typeLibelle,
    this.latitude,
    this.longitude,
  });

  bool get estGeolocalisee => latitude != null && longitude != null;

  factory CommoditeModel.fromJson(Map<String, dynamic> json) {
    return CommoditeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      icone: json['icone'] as String?,
      description: json['description'] as String?,
      typeLibelle: json['typeCommoditeLibelle'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Liste tolérante (absente, nulle ou mal typée → liste vide).
  static List<CommoditeModel> listFromJson(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CommoditeModel.fromJson)
        .toList();
  }

  @override
  List<Object?> get props =>
      [id, nom, icone, description, typeLibelle, latitude, longitude];
}
