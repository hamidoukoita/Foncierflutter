import 'package:equatable/equatable.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/bien_libelle.dart';

/// Rendez-vous (visite au siège ou sur chantier) — miroir de `RendezVousResponse`.
class RendezVousModel extends Equatable {
  /// Durée appliquée quand le créneau ne précise pas d'heure de fin.
  static const Duration dureeParDefaut = Duration(hours: 1);

  final int id;
  final DateTime dateRendezVous;
  final String typeRDV; // SIEGE | CHANTIER
  final String statut; // EN_ATTENTE | ACCEPTER | REFUSER
  final String? lieu;
  final String? motifRefus;
  final String? compteRendu;
  final DateTime? dateTraitement;

  final int? acquereurId;
  final String? acquereurNom;
  final String? acquereurTelephone;

  final int? agentId;
  final String? agentNom;

  final int? bienId;
  final String? bienReference;
  final String? bienDesignation;
  final String? programmeNom;

  final int? creneauId;
  final String? creneauHeure;
  final String? creneauHeureDebut; // "HH:mm" ou "HH:mm:ss"
  final String? creneauHeureFin;

  const RendezVousModel({
    required this.id,
    required this.dateRendezVous,
    required this.typeRDV,
    required this.statut,
    this.lieu,
    this.motifRefus,
    this.compteRendu,
    this.dateTraitement,
    this.acquereurId,
    this.acquereurNom,
    this.acquereurTelephone,
    this.agentId,
    this.agentNom,
    this.bienId,
    this.bienReference,
    this.bienDesignation,
    this.programmeNom,
    this.creneauId,
    this.creneauHeure,
    this.creneauHeureDebut,
    this.creneauHeureFin,
  });

  bool get estSurChantier => typeRDV == 'CHANTIER';

  bool get aCompteRendu =>
      compteRendu != null && compteRendu!.trim().isNotEmpty;

  /// Début effectif : heure de début du créneau si connue, sinon date du RDV.
  DateTime get debut => _appliquerHeure(creneauHeureDebut) ?? dateRendezVous;

  DateTime get fin =>
      _appliquerHeure(creneauHeureFin) ?? debut.add(dureeParDefaut);

  /// "Lot 05" / "Parcelle PARC-012"
  String get libelleBien => BienLibelle.court(
        designation: bienDesignation,
        reference: bienReference,
        programmeNom: programmeNom,
      );

  /// "Résidence Les Palmiers • Lot 05"
  String get localisation => BienLibelle.joindre([programmeNom, libelleBien]);

  DateTime? _appliquerHeure(String? heure) {
    if (heure == null || heure.isEmpty) return null;
    final parties = heure.split(':');
    final h = int.tryParse(parties.first);
    final m = parties.length > 1 ? int.tryParse(parties[1]) : 0;
    if (h == null || m == null) return null;
    return DateTime(
        dateRendezVous.year, dateRendezVous.month, dateRendezVous.day, h, m);
  }

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    return RendezVousModel(
      id: json['id'] as int,
      dateRendezVous: DateTime.parse(json['dateRendezVous'] as String),
      typeRDV: json['typeRDV'] as String? ?? 'SIEGE',
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      lieu: json['lieu'] as String?,
      motifRefus: json['motifRefus'] as String?,
      compteRendu: json['compteRendu'] as String?,
      dateTraitement: json['dateTraitement'] != null
          ? DateTime.parse(json['dateTraitement'] as String)
          : null,
      acquereurId: json['acquereurId'] as int?,
      acquereurNom: json['acquereurNom'] as String?,
      acquereurTelephone: json['acquereurTelephone'] as String?,
      agentId: json['agentId'] as int?,
      agentNom: json['agentNom'] as String?,
      bienId: json['bienId'] as int?,
      bienReference: json['bienReference'] as String?,
      bienDesignation: json['bienDesignation'] as String?,
      programmeNom: json['programmeNom'] as String?,
      creneauId: json['creneauId'] as int?,
      creneauHeure: json['creneauHeure'] as String?,
      creneauHeureDebut: json['creneauHeureDebut'] as String?,
      creneauHeureFin: json['creneauHeureFin'] as String?,
    );
  }

  /// Corps attendu par `PUT /rendez-vous/{id}` (`RendezVousRequest`).
  /// Le backend remplace tous les champs : on renvoie donc l'objet complet.
  Map<String, dynamic> toRequestJson({String? compteRendu}) => {
        'dateRendezVous': dateRendezVous.toIso8601String(),
        'typeRDV': typeRDV,
        'statut': statut,
        'lieu': lieu,
        'motifRefus': motifRefus,
        'compteRendu': compteRendu ?? this.compteRendu,
        'acquereurId': acquereurId,
        'agentId': agentId,
        'bienId': bienId,
        'creneauId': creneauId,
      };

  @override
  List<Object?> get props => [
        id,
        dateRendezVous,
        typeRDV,
        statut,
        lieu,
        motifRefus,
        compteRendu,
        dateTraitement,
        acquereurId,
        acquereurNom,
        acquereurTelephone,
        agentId,
        agentNom,
        bienId,
        bienReference,
        bienDesignation,
        programmeNom,
        creneauId,
        creneauHeure,
        creneauHeureDebut,
        creneauHeureFin,
      ];
}
