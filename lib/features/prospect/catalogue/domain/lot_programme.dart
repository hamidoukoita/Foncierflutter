class LotProgramme {
  final int id;
  final String? reference;
  final String? numeroLot;
  final String? numeroIlot;
  final double? superficie;
  final double? prix;
  final double? facade;
  final double? profondeur;
  final String? statut;
  final int? programmeId;
  final String? programmeNom;
  final String? geometryJson;
  final bool? reservationMultiple;
  final double? latitude;
  final double? longitude;

  const LotProgramme({
    required this.id,
    this.reference,
    this.numeroLot,
    this.numeroIlot,
    this.superficie,
    this.prix,
    this.facade,
    this.profondeur,
    this.statut,
    this.programmeId,
    this.programmeNom,
    this.geometryJson,
    this.reservationMultiple,
    this.latitude,
    this.longitude,
  });

  String get displayRef =>
      reference?.isNotEmpty == true
          ? reference!
          : (numeroLot?.isNotEmpty == true ? 'Lot $numeroLot' : 'Lot #$id');

  bool get isDisponible {
    final s = (statut ?? '').toUpperCase();
    // startsWith : « INDISPONIBLE » contient « DISPON » mais n'est pas réservable.
    return s.startsWith('DISPON') || s == 'PUBLIE' || s == 'LIBRE';
  }

  bool get isReserve => (statut ?? '').toUpperCase().contains('RESERV');

  /// Réservable si disponible, ou déjà réservé mais ouvert aux réservations multiples.
  bool get peutEtreReserve =>
      isDisponible || (isReserve && reservationMultiple == true);

  factory LotProgramme.fromJson(Map<String, dynamic> json) {
    return LotProgramme(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reference: json['reference'] as String?,
      numeroLot: json['numeroLot'] as String?,
      numeroIlot: json['numeroIlot'] as String?,
      superficie: (json['superficie'] as num?)?.toDouble(),
      prix: (json['prix'] as num?)?.toDouble(),
      facade: (json['facade'] as num?)?.toDouble(),
      profondeur: (json['profondeur'] as num?)?.toDouble(),
      statut: json['statut']?.toString(),
      programmeId: (json['programmeId'] as num?)?.toInt(),
      programmeNom: json['programmeNom'] as String?,
      geometryJson: json['geometryJson'] as String?,
      reservationMultiple: json['reservationMultiple'] as bool?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
