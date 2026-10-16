import 'package:equatable/equatable.dart';
import 'package:flutter_mobile_prospect_agent/data/models/commodite_model.dart';

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
  final String? typeBien; // LOT_PROGRAMME, PARCELLE_INDIVIDUELLE ou MAISON_CLE_EN_MAIN

  /// Titre de l'annonce d'une maison clé en main.
  final String? titre;

  // Champs spécifiques au LotProgramme
  final String? numeroLot;
  final String? numeroIlot;
  final String? numeroIlotLotissement;
  final int? programmeId;
  final String? programmeNom;
  final String? localisation;
  final String? imageUrl;

  /// Nombre de panoramas 360° ajoutés par la société.
  final int nombrePanoramas;

  // Champs spécifiques à la ParcelleIndividuelle
  final String? numeroTitreFoncier;
  final bool? murCloture;
  final bool? eauSomapep;
  final bool? electriciteEdm;
  final bool? voieBitumee;
  final int? societeId;
  final String? societeNom;
  /// Logo de la société promotrice (chemin relatif servi par le backend).
  final String? societeLogoUrl;

  /// true = le bien accepte plusieurs réservations actives en parallèle (réglé par la société promotrice).
  final bool? reservationMultiple;

  /// Commodités associées (`biens_commodites`).
  final List<CommoditeModel> commodites;

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
    this.titre,
    this.numeroLot,
    this.numeroIlot,
    this.numeroIlotLotissement,
    this.programmeId,
    this.programmeNom,
    this.localisation,
    this.imageUrl,
    this.nombrePanoramas = 0,
    this.numeroTitreFoncier,
    this.murCloture,
    this.eauSomapep,
    this.electriciteEdm,
    this.voieBitumee,
    this.societeId,
    this.societeNom,
    this.societeLogoUrl,
    this.reservationMultiple,
    this.commodites = const [],
  });

  bool get aDesCoordonnees => latitude != null && longitude != null;

  bool get isLot =>
      (typeBien ?? '').toUpperCase().contains('LOT') || numeroLot != null;

  bool get isMaison => typeBien == 'MAISON_CLE_EN_MAIN';

  /// Libellé affichable : « Lot 12 · Îlot B », « Parcelle A-12 » ou le titre d'une maison.
  String get designation => isMaison && (titre ?? '').isNotEmpty
      ? titre!
      : isLot
      ? 'Lot ${numeroLot ?? reference}${numeroIlot != null ? ' · Îlot $numeroIlot' : ''}'
      : (reference.isNotEmpty ? reference : 'Parcelle #$id');

  bool get isDisponible => statut.toUpperCase() == 'DISPONIBLE';
  bool get isReserve => statut.toUpperCase() == 'RESERVER';

  /// Réservable si disponible, ou déjà réservé mais ouvert aux réservations multiples.
  bool get peutEtreReserve =>
      isDisponible || (isReserve && reservationMultiple == true);

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
      titre: json['titre'] as String?,
      numeroLot: json['numeroLot'] as String?,
      numeroIlot: json['numeroIlot'] as String?,
      numeroIlotLotissement: json['numeroIlotLotissement'] as String?,
      programmeId: json['programmeId'] as int?,
      programmeNom: json['programmeNom'] as String?,
      localisation: _firstText(json, const ['lieu', 'localisation', 'adresse', 'programmeLieu']),
      imageUrl: _firstText(json, const ['imageUrl', 'urlImage', 'photoUrl', 'imagePrincipale']),
      nombrePanoramas: (json['nombrePanoramas'] as num?)?.toInt() ?? 0,
      numeroTitreFoncier: json['numeroTitreFoncier'] as String?,
      murCloture: json['murCloture'] as bool?,
      eauSomapep: json['eauSomapep'] as bool?,
      electriciteEdm: json['electriciteEdm'] as bool?,
      voieBitumee: json['voieBitumee'] as bool?,
      societeId: json['societeId'] as int?,
      societeNom: json['societeNom'] as String?,
      societeLogoUrl: json['societeLogoUrl'] as String?,
      reservationMultiple: json['reservationMultiple'] as bool?,
      commodites: CommoditeModel.listFromJson(json['commodites']),
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
        'nombrePanoramas': nombrePanoramas,
        'numeroTitreFoncier': numeroTitreFoncier,
        'murCloture': murCloture,
        'eauSomapep': eauSomapep,
        'electriciteEdm': electriciteEdm,
        'voieBitumee': voieBitumee,
        'societeId': societeId,
        'societeNom': societeNom,
        'societeLogoUrl': societeLogoUrl,
        'reservationMultiple': reservationMultiple,
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
        nombrePanoramas,
        numeroTitreFoncier,
        murCloture,
        eauSomapep,
        electriciteEdm,
        voieBitumee,
        societeId,
        societeNom,
        societeLogoUrl,
        reservationMultiple,
        commodites,
      ];
}

String? _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}
