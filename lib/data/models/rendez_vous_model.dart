import 'package:equatable/equatable.dart';

/// Rendez-vous de visite — miroir de `RendezVousResponse` (Spring Boot).
///
/// Statuts backend : EN_ATTENTE, ACCEPTER, REFUSER. Types : SIEGE, CHANTIER.
class RendezVousModel extends Equatable {
  final int id;
  final DateTime dateRendezVous;
  final String typeRDV; // SIEGE | CHANTIER
  final String statut; // EN_ATTENTE | ACCEPTER | REFUSER
  final String? lieu;
  final String? motifRefus;
  final String? compteRendu;

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

  const RendezVousModel({
    required this.id,
    required this.dateRendezVous,
    required this.typeRDV,
    required this.statut,
    this.lieu,
    this.motifRefus,
    this.compteRendu,
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
  });

  /// Compatibilité avec l'ancien modèle (écrans agent).
  String get dateHeure => dateRendezVous.toIso8601String();
  String? get typeVisite => typeRDV;
  String? get motif => motifRefus;

  bool get isEnAttente => statut == 'EN_ATTENTE';
  bool get isAccepte => statut == 'ACCEPTER';
  bool get isRefuse => statut == 'REFUSER';
  bool get isAnnule => isRefuse && (motifRefus ?? '').toLowerCase().startsWith('annul');
  bool get isChantier => typeRDV == 'CHANTIER';

  /// À venir = pas refusé et pas encore passé.
  bool get isAVenir => !isRefuse && dateRendezVous.isAfter(DateTime.now());

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    // Tolère l'ancien nom de champ « dateHeure ».
    final rawDate = (json['dateRendezVous'] ?? json['dateHeure']) as String?;
    return RendezVousModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dateRendezVous:
          rawDate != null ? (DateTime.tryParse(rawDate) ?? DateTime.now()) : DateTime.now(),
      typeRDV: (json['typeRDV'] ?? json['typeVisite'] ?? 'SIEGE').toString(),
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      lieu: json['lieu'] as String?,
      motifRefus: json['motifRefus'] as String?,
      compteRendu: json['compteRendu'] as String?,
      acquereurId: (json['acquereurId'] as num?)?.toInt(),
      acquereurNom: json['acquereurNom'] as String?,
      acquereurTelephone: json['acquereurTelephone'] as String?,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentNom: json['agentNom'] as String?,
      bienId: (json['bienId'] as num?)?.toInt(),
      bienReference: json['bienReference'] as String?,
      bienDesignation: json['bienDesignation'] as String?,
      programmeNom: json['programmeNom'] as String?,
      creneauId: (json['creneauId'] as num?)?.toInt(),
      creneauHeure: json['creneauHeure'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateRendezVous': dateRendezVous.toIso8601String(),
        'typeRDV': typeRDV,
        'statut': statut,
        'lieu': lieu,
        'motifRefus': motifRefus,
        'compteRendu': compteRendu,
        'acquereurId': acquereurId,
        'acquereurNom': acquereurNom,
        'acquereurTelephone': acquereurTelephone,
        'agentId': agentId,
        'agentNom': agentNom,
        'bienId': bienId,
        'bienReference': bienReference,
        'bienDesignation': bienDesignation,
        'programmeNom': programmeNom,
        'creneauId': creneauId,
        'creneauHeure': creneauHeure,
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
      ];
}
