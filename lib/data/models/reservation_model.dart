import 'package:equatable/equatable.dart';

class ReservationModel extends Equatable {
  final int id;
  final String numeroDossier;
  final DateTime dateReservation;
  final DateTime dateExpiration;
  final String statut;
  final String? motifRefus;
  final DateTime? dateTraitement;

  final int? bienId;
  final String? bienReference;
  final String? bienDesignation;
  final String? programmeNom;
  final double? montant;

  final int? acquereurId;
  final String? acquereurNom;
  final String? acquereurTelephone;

  final int? agentId;
  final String? agentNom;

  const ReservationModel({
    required this.id,
    required this.numeroDossier,
    required this.dateReservation,
    required this.dateExpiration,
    required this.statut,
    this.motifRefus,
    this.dateTraitement,
    this.bienId,
    this.bienReference,
    this.bienDesignation,
    this.programmeNom,
    this.montant,
    this.acquereurId,
    this.acquereurNom,
    this.acquereurTelephone,
    this.agentId,
    this.agentNom,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final dateRes = json['dateReservation'] != null
        ? DateTime.parse(json['dateReservation'])
        : DateTime.now();

    return ReservationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      numeroDossier: json['numeroDossier'] as String? ?? '',
      dateReservation: dateRes,
      // Si le backend ne l'envoie pas, on applique la règle locale de 24h
      dateExpiration: json['dateExpiration'] != null
          ? DateTime.parse(json['dateExpiration'])
          : dateRes.add(const Duration(hours: 24)),
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      motifRefus: json['motifRefus'] as String?,
      dateTraitement: json['dateTraitement'] != null
          ? DateTime.parse(json['dateTraitement'])
          : null,
      bienId: (json['bienId'] as num?)?.toInt(),
      bienReference: json['bienReference'] as String?,
      bienDesignation: json['bienDesignation'] as String?,
      programmeNom: json['programmeNom'] as String?,
      montant: (json['montant'] as num?)?.toDouble(),
      acquereurId: (json['acquereurId'] as num?)?.toInt(),
      acquereurNom: json['acquereurNom'] as String?,
      acquereurTelephone: json['acquereurTelephone'] as String?,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentNom: json['agentNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numeroDossier': numeroDossier,
        'dateReservation': dateReservation.toIso8601String(),
        'dateExpiration': dateExpiration.toIso8601String(),
        'statut': statut,
        'motifRefus': motifRefus,
        'dateTraitement': dateTraitement?.toIso8601String(),
        'bienId': bienId,
        'bienReference': bienReference,
        'bienDesignation': bienDesignation,
        'programmeNom': programmeNom,
        'montant': montant,
        'acquereurId': acquereurId,
        'acquereurNom': acquereurNom,
        'acquereurTelephone': acquereurTelephone,
        'agentId': agentId,
        'agentNom': agentNom,
      };

  @override
  List<Object?> get props => [
        id,
        numeroDossier,
        dateReservation,
        dateExpiration,
        statut,
        motifRefus,
        dateTraitement,
        bienId,
        bienReference,
        bienDesignation,
        programmeNom,
        montant,
        acquereurId,
        acquereurNom,
        acquereurTelephone,
        agentId,
        agentNom,
      ];
}
