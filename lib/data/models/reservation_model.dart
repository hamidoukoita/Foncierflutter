import 'package:equatable/equatable.dart';

/// Cycle d'une réservation : payée → en attente d'un agent → décompte démarré par l'agent (en cours)
/// → vendue avant l'échéance, ou expirée. L'acquéreur peut annuler tant que le bien n'est pas vendu.
enum StatutReservation {
  enAttente,
  enCours,
  vendue,
  expiree,
  annulee;

  /// Les anciens dossiers (CONFIRMER, REFUSER) sont rattachés au nouveau cycle.
  static StatutReservation depuis(String? code) {
    switch (code) {
      case 'EN_COURS':
      case 'CONFIRMER':
        return StatutReservation.enCours;
      case 'VENDUE':
        return StatutReservation.vendue;
      case 'EXPIREE':
        return StatutReservation.expiree;
      case 'ANNULEE':
      case 'REFUSER':
        return StatutReservation.annulee;
      default:
        return StatutReservation.enAttente;
    }
  }
}

class ReservationModel extends Equatable {
  final int id;
  final String numeroDossier;
  final DateTime dateReservation;
  final String statut;
  final String? motifAnnulation;
  final DateTime? dateTraitement;

  /// Décompte démarré par l'agent, jusqu'à [dateExpiration] (toutes deux nulles avant).
  final DateTime? dateDebutDecompte;
  final DateTime? dateExpiration;
  final DateTime? dateConclusion;
  final int? dureeReservationHeures;

  final int? bienId;
  final String? bienReference;
  final String? bienDesignation;
  final String? programmeNom;

  /// Prix de vente du bien.
  final double? montant;

  // Paiement Orange Money simulé.
  final double montantReservation;
  final String? referencePaiement;
  final DateTime? datePaiement;
  final bool rembourse;

  final int? acquereurId;
  final String? acquereurNom;
  final String? acquereurTelephone;

  final int? agentId;
  final String? agentNom;

  const ReservationModel({
    required this.id,
    required this.numeroDossier,
    required this.dateReservation,
    required this.statut,
    this.motifAnnulation,
    this.dateTraitement,
    this.dateDebutDecompte,
    this.dateExpiration,
    this.dateConclusion,
    this.dureeReservationHeures,
    this.bienId,
    this.bienReference,
    this.bienDesignation,
    this.programmeNom,
    this.montant,
    this.montantReservation = 0,
    this.referencePaiement,
    this.datePaiement,
    this.rembourse = false,
    this.acquereurId,
    this.acquereurNom,
    this.acquereurTelephone,
    this.agentId,
    this.agentNom,
  });

  StatutReservation get etape => StatutReservation.depuis(statut);

  bool get isEnAttente => etape == StatutReservation.enAttente;
  bool get isEnCours => etape == StatutReservation.enCours;
  bool get isVendue => etape == StatutReservation.vendue;
  bool get isExpiree => etape == StatutReservation.expiree;
  bool get isAnnulee => etape == StatutReservation.annulee;

  /// La réservation bloque encore le bien : l'acquéreur peut l'annuler.
  bool get estActive => isEnAttente || isEnCours;

  bool get estPayante => montantReservation > 0;

  bool get decompteDemarre => dateDebutDecompte != null && dateExpiration != null;

  /// Temps restant avant l'échéance du décompte ; null s'il n'a pas démarré.
  Duration? tempsRestant([DateTime? maintenant]) {
    if (!isEnCours || dateExpiration == null) return null;
    final restant = dateExpiration!.difference(maintenant ?? DateTime.now());
    return restant.isNegative ? Duration.zero : restant;
  }

  /// Part de la durée déjà écoulée (0 → 1) ; null s'il n'y a pas de décompte.
  double? progression([DateTime? maintenant]) {
    if (!decompteDemarre) return null;
    final total = dateExpiration!.difference(dateDebutDecompte!).inSeconds;
    if (total <= 0) return 1;
    final ecoule = (maintenant ?? DateTime.now()).difference(dateDebutDecompte!).inSeconds;
    return (ecoule / total).clamp(0.0, 1.0);
  }

  static DateTime? _date(Object? v) => v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      numeroDossier: json['numeroDossier'] as String? ?? '',
      dateReservation: _date(json['dateReservation']) ?? DateTime.now(),
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      motifAnnulation: (json['motifAnnulation'] ?? json['motifRefus']) as String?,
      dateTraitement: _date(json['dateTraitement']),
      dateDebutDecompte: _date(json['dateDebutDecompte']),
      dateExpiration: _date(json['dateExpiration']),
      dateConclusion: _date(json['dateConclusion']),
      dureeReservationHeures: (json['dureeReservationHeures'] as num?)?.toInt(),
      bienId: (json['bienId'] as num?)?.toInt(),
      bienReference: json['bienReference'] as String?,
      bienDesignation: json['bienDesignation'] as String?,
      programmeNom: json['programmeNom'] as String?,
      montant: (json['montant'] as num?)?.toDouble(),
      montantReservation: (json['montantReservation'] as num?)?.toDouble() ?? 0,
      referencePaiement: json['referencePaiement'] as String?,
      datePaiement: _date(json['datePaiement']),
      rembourse: json['rembourse'] as bool? ?? false,
      acquereurId: (json['acquereurId'] as num?)?.toInt(),
      acquereurNom: json['acquereurNom'] as String?,
      acquereurTelephone: json['acquereurTelephone'] as String?,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentNom: json['agentNom'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        numeroDossier,
        dateReservation,
        statut,
        motifAnnulation,
        dateTraitement,
        dateDebutDecompte,
        dateExpiration,
        dateConclusion,
        dureeReservationHeures,
        bienId,
        bienReference,
        bienDesignation,
        programmeNom,
        montant,
        montantReservation,
        referencePaiement,
        datePaiement,
        rembourse,
        acquereurId,
        acquereurNom,
        acquereurTelephone,
        agentId,
        agentNom,
      ];
}

/// Conditions de réservation d'un bien, connues avant de payer.
class ConditionsReservation {
  final int bienId;
  final double montant;
  final bool payante;
  final int dureeHeures;
  final bool reservationMultiple;
  final bool reservable;
  final String? motifIndisponibilite;
  final String? societeNom;

  const ConditionsReservation({
    required this.bienId,
    required this.montant,
    required this.payante,
    required this.dureeHeures,
    required this.reservationMultiple,
    required this.reservable,
    this.motifIndisponibilite,
    this.societeNom,
  });

  factory ConditionsReservation.fromJson(Map<String, dynamic> json) {
    return ConditionsReservation(
      bienId: (json['bienId'] as num?)?.toInt() ?? 0,
      montant: (json['montant'] as num?)?.toDouble() ?? 0,
      payante: json['payante'] as bool? ?? false,
      dureeHeures: (json['dureeHeures'] as num?)?.toInt() ?? 72,
      reservationMultiple: json['reservationMultiple'] as bool? ?? false,
      reservable: json['reservable'] as bool? ?? false,
      motifIndisponibilite: json['motifIndisponibilite'] as String?,
      societeNom: json['societeNom'] as String?,
    );
  }
}
