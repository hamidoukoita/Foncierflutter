import 'package:equatable/equatable.dart';
import 'package:flutter_mobile_prospect_agent/data/models/commodite_model.dart';

/// Commodité rattachée à une cité ou à une parcelle, avec la distance
/// déclarée par la société — miroir de `ProximiteCommoditeResponse`.
class ProximiteCommoditeModel extends Equatable {
  final int id;
  final double? distanceKm;
  final CommoditeModel commodite;

  const ProximiteCommoditeModel({
    required this.id,
    required this.commodite,
    this.distanceKm,
  });

  factory ProximiteCommoditeModel.fromJson(Map<String, dynamic> json) {
    return ProximiteCommoditeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      commodite: CommoditeModel.fromJson(
        json['commodite'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  static List<ProximiteCommoditeModel> listFromJson(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProximiteCommoditeModel.fromJson)
        .toList();
  }

  @override
  List<Object?> get props => [id, distanceKm, commodite];
}
