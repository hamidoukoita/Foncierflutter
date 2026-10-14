/// Maison clé en main publiée par une société agréée.
class MaisonCleEnMain {
  final int id;
  final String reference;
  final String titre;
  final String? description;
  final double prix;
  final double superficie;
  final double? surfaceHabitable;
  final int? nombreChambres;
  final int? nombreSallesBain;
  final int? nombreNiveaux;
  final String? numeroTitreFoncier;
  final String? adresse;
  final double? latitude;
  final double? longitude;
  final String statut;
  final bool reservationMultiple;
  final String? imageUrl;
  final int nombrePanoramas;
  final int? societeId;
  final String? societeNom;
  final List<String> equipements;

  const MaisonCleEnMain({
    required this.id,
    required this.reference,
    required this.titre,
    required this.prix,
    required this.superficie,
    required this.statut,
    this.description,
    this.surfaceHabitable,
    this.nombreChambres,
    this.nombreSallesBain,
    this.nombreNiveaux,
    this.numeroTitreFoncier,
    this.adresse,
    this.latitude,
    this.longitude,
    this.reservationMultiple = false,
    this.imageUrl,
    this.nombrePanoramas = 0,
    this.societeId,
    this.societeNom,
    this.equipements = const [],
  });

  bool get isDisponible => statut == 'DISPONIBLE';
  bool get isReserve => statut == 'RESERVER';

  /// Mêmes règles que les autres biens : disponible, ou réservée mais ouverte à plusieurs réservations.
  bool get peutEtreReserve => isDisponible || (isReserve && reservationMultiple);

  /// « Plain-pied », « R+1 », « R+2 »…
  String? get niveaux {
    final n = nombreNiveaux;
    if (n == null || n <= 0) return null;
    return n == 1 ? 'Plain-pied' : 'R+${n - 1}';
  }

  factory MaisonCleEnMain.fromJson(Map<String, dynamic> json) {
    double? d(String k) => (json[k] as num?)?.toDouble();
    int? i(String k) => (json[k] as num?)?.toInt();
    return MaisonCleEnMain(
      id: (json['id'] as num).toInt(),
      reference: json['reference'] as String? ?? '',
      titre: json['titre'] as String? ?? 'Maison',
      description: json['description'] as String?,
      prix: d('prix') ?? 0,
      superficie: d('superficie') ?? 0,
      surfaceHabitable: d('surfaceHabitable'),
      nombreChambres: i('nombreChambres'),
      nombreSallesBain: i('nombreSallesBain'),
      nombreNiveaux: i('nombreNiveaux'),
      numeroTitreFoncier: json['numeroTitreFoncier'] as String?,
      adresse: json['adresse'] as String?,
      latitude: d('latitude'),
      longitude: d('longitude'),
      statut: json['statut'] as String? ?? 'DISPONIBLE',
      reservationMultiple: json['reservationMultiple'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      nombrePanoramas: i('nombrePanoramas') ?? 0,
      societeId: i('societeId'),
      societeNom: json['societeNom'] as String?,
      equipements: ((json['equipements'] as List?) ?? const []).map((e) => e.toString()).toList(),
    );
  }
}
