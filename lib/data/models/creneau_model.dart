import 'package:equatable/equatable.dart';

/// Créneau de visite d'une société promotrice — miroir de `CreneauResponse`.
class CreneauModel extends Equatable {
  final int id;
  final String heure; // libellé, ex. « 09h00 - 10h00 »
  final String? heureDebut; // « HH:mm:ss »
  final String? heureFin;
  final bool disponible;
  final int? societeId;

  const CreneauModel({
    required this.id,
    required this.heure,
    this.heureDebut,
    this.heureFin,
    this.disponible = true,
    this.societeId,
  });

  factory CreneauModel.fromJson(Map<String, dynamic> json) {
    return CreneauModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      heure: json['heure'] as String? ?? '',
      heureDebut: json['heureDebut'] as String?,
      heureFin: json['heureFin'] as String?,
      disponible: json['disponible'] as bool? ?? true,
      societeId: (json['societeId'] as num?)?.toInt(),
    );
  }

  List<String> get _debutParts => (heureDebut ?? '').split(':');

  /// Heure de début (0-23) ; null si absente ou illisible.
  int? get debutHeure => _debutParts.length >= 2 ? int.tryParse(_debutParts[0]) : null;

  /// Minutes de début (0-59) ; null si absente ou illisible.
  int? get debutMinute => _debutParts.length >= 2 ? int.tryParse(_debutParts[1]) : null;

  String get libelle {
    if (heure.isNotEmpty) return heure;
    final d = heureDebut, f = heureFin;
    if (d != null && f != null) {
      return '${d.substring(0, 5)} - ${f.substring(0, 5)}';
    }
    return d != null ? d.substring(0, 5) : 'Créneau #$id';
  }

  @override
  List<Object?> get props => [id, heure, heureDebut, heureFin, disponible, societeId];
}
