import 'package:equatable/equatable.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/bien_libelle.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';

/// Rendez-vous de visite — miroir de `RendezVousResponse` (Spring Boot).
///
/// Statuts backend : EN_ATTENTE, ACCEPTER, REFUSER. Types : SIEGE, CHANTIER.
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

  /// Compatibilité avec l'ancien modèle (écrans agent).
  String get dateHeure => dateRendezVous.toIso8601String();
  String? get typeVisite => typeRDV;
  String? get motif => motifRefus;

  bool get isEnAttente => statut == 'EN_ATTENTE';
  bool get isAccepte => statut == 'ACCEPTER';
  bool get isRefuse => statut == 'REFUSER';
  bool get isChantier => typeRDV == 'CHANTIER';

  /// À venir = pas refusé et pas encore passé.
  bool get isAVenir => !isRefuse && dateRendezVous.isAfter(DateTime.now());

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
    // Tolère l'ancien nom de champ « dateHeure ».
    final rawDate = (json['dateRendezVous'] ?? json['dateHeure']) as String?;
    return RendezVousModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dateRendezVous: rawDate != null
          ? (DateTime.tryParse(rawDate) ?? DateTime.now())
          : DateTime.now(),
      typeRDV: (json['typeRDV'] ?? json['typeVisite'] ?? 'SIEGE').toString(),
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      lieu: json['lieu'] as String?,
      motifRefus: json['motifRefus'] as String?,
      compteRendu: json['compteRendu'] as String?,
      dateTraitement:
          DateTime.tryParse(json['dateTraitement'] as String? ?? ''),
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
      creneauHeureDebut: json['creneauHeureDebut'] as String?,
      creneauHeureFin: json['creneauHeureFin'] as String?,
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

  /// Corps attendu par `PUT /rendez-vous/{id}` (`RendezVousRequest`).
  /// Le backend remplace tous les champs : on renvoie donc l'objet complet.
  Map<String, dynamic> toRequestJson({String? compteRendu}) => {
        'dateRendezVous': DateFormatter.isoLocal(dateRendezVous),
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
