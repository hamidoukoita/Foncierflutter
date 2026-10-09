import 'package:equatable/equatable.dart';

class BienFoncierModel extends Equatable {
  final int id;
  final String reference;
  final double superficie;
  final double prix;
  final double? facade;
  final double? profondeur;
  final double? latitude;
  final double? longitude;
  final String statut;
  final String? typeBien; // "LOT_PROGRAMME" ou "PARCELLE_INDIVIDUELLE"

  // Champs spécifiques au LotProgramme
  final String? numeroLot;
  final String? numeroIlot;
  final String? numeroIlotLotissement;
  final int? programmeId;
  final String? programmeNom;
  final String? localisation;
  final String? imageUrl;

  // Champs spécifiques à la ParcelleIndividuelle
  final String? numeroTitreFoncier;
  final bool? murCloture;
  final bool? eauSomapep;
  final bool? electriciteEdm;
  final bool? voieBitumee;
  final int? societeId;
  final String? societeNom;

  const BienFoncierModel({
    required this.id,
    required this.reference,
    required this.superficie,
    required this.prix,
    this.facade,
    this.profondeur,
    this.latitude,
    this.longitude,
    required this.statut,
    this.typeBien,
    this.numeroLot,
    this.numeroIlot,
    this.numeroIlotLotissement,
    this.programmeId,
    this.programmeNom,
    this.localisation,
    this.imageUrl,
    this.numeroTitreFoncier,
    this.murCloture,
    this.eauSomapep,
    this.electriciteEdm,
    this.voieBitumee,
    this.societeId,
    this.societeNom,
  });

  factory BienFoncierModel.fromJson(Map<String, dynamic> json) {
    return BienFoncierModel(
      id: json['id'] as int,
      reference: json['reference'] as String? ?? '',
      superficie: (json['superficie'] as num?)?.toDouble() ?? 0.0,
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      facade: (json['facade'] as num?)?.toDouble(),
      profondeur: (json['profondeur'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      statut: json['statut'] as String? ?? 'DISPONIBLE',
      typeBien: json['typeBien'] as String?,
      numeroLot: json['numeroLot'] as String?,
      numeroIlot: json['numeroIlot'] as String?,
      numeroIlotLotissement: json['numeroIlotLotissement'] as String?,
      programmeId: json['programmeId'] as int?,
      programmeNom: json['programmeNom'] as String?,
      localisation: _firstText(json, const ['lieu', 'localisation', 'adresse', 'programmeLieu']),
      imageUrl: _firstText(json, const ['imageUrl', 'urlImage', 'photoUrl', 'imagePrincipale']),
      numeroTitreFoncier: json['numeroTitreFoncier'] as String?,
      murCloture: json['murCloture'] as bool?,
      eauSomapep: json['eauSomapep'] as bool?,
      electriciteEdm: json['electriciteEdm'] as bool?,
      voieBitumee: json['voieBitumee'] as bool?,
      societeId: json['societeId'] as int?,
      societeNom: json['societeNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'superficie': superficie,
        'prix': prix,
        'facade': facade,
        'profondeur': profondeur,
        'latitude': latitude,
        'longitude': longitude,
        'statut': statut,
        'typeBien': typeBien,
        'numeroLot': numeroLot,
        'numeroIlot': numeroIlot,
        'numeroIlotLotissement': numeroIlotLotissement,
        'programmeId': programmeId,
        'programmeNom': programmeNom,
        'localisation': localisation,
        'imageUrl': imageUrl,
        'numeroTitreFoncier': numeroTitreFoncier,
        'murCloture': murCloture,
        'eauSomapep': eauSomapep,
        'electriciteEdm': electriciteEdm,
        'voieBitumee': voieBitumee,
        'societeId': societeId,
        'societeNom': societeNom,
      };

  @override
  List<Object?> get props => [
        id,
        reference,
        superficie,
        prix,
        facade,
        profondeur,
        latitude,
        longitude,
        statut,
        typeBien,
        numeroLot,
        numeroIlot,
        numeroIlotLotissement,
        programmeId,
        programmeNom,
        localisation,
        imageUrl,
        numeroTitreFoncier,
        murCloture,
        eauSomapep,
        electriciteEdm,
        voieBitumee,
        societeId,
        societeNom,
      ];
}

String? _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}
