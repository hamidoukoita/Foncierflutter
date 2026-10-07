import 'package:equatable/equatable.dart';

class RendezVousModel extends Equatable {
  final int id;
  final String dateHeure;
  final String statut;
  final String? motif;
  final String? typeVisite; // SIEGE vs CHANTIER

  final int? acquereurId;
  final String? acquereurNom;
  final String? acquereurTelephone;

  final int? agentId;
  final String? agentNom;

  final int? programmeId;
  final String? programmeNom;

  const RendezVousModel({
    required this.id,
    required this.dateHeure,
    required this.statut,
    this.motif,
    this.typeVisite,
    this.acquereurId,
    this.acquereurNom,
    this.acquereurTelephone,
    this.agentId,
    this.agentNom,
    this.programmeId,
    this.programmeNom,
  });

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    return RendezVousModel(
      id: json['id'] as int,
      dateHeure: json['dateHeure'] as String? ?? '',
      statut: json['statut'] as String? ?? 'PLANIFIE',
      motif: json['motif'] as String?,
      typeVisite: json['typeVisite'] as String?,
      acquereurId: json['acquereurId'] as int?,
      acquereurNom: json['acquereurNom'] as String?,
      acquereurTelephone: json['acquereurTelephone'] as String?,
      agentId: json['agentId'] as int?,
      agentNom: json['agentNom'] as String?,
      programmeId: json['programmeId'] as int?,
      programmeNom: json['programmeNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateHeure': dateHeure,
        'statut': statut,
        'motif': motif,
        'typeVisite': typeVisite,
        'acquereurId': acquereurId,
        'acquereurNom': acquereurNom,
        'acquereurTelephone': acquereurTelephone,
        'agentId': agentId,
        'agentNom': agentNom,
        'programmeId': programmeId,
        'programmeNom': programmeNom,
      };

  @override
  List<Object?> get props => [
        id,
        dateHeure,
        statut,
        motif,
        typeVisite,
        acquereurId,
        acquereurNom,
        acquereurTelephone,
        agentId,
        agentNom,
        programmeId,
        programmeNom,
      ];
}
