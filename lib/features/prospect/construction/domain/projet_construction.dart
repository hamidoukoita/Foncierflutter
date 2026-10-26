import 'description_maison.dart';
import 'echange_projet.dart';

/// Types de pièces jointes acceptés par le backend.
enum TypeFichierProjet {
  titreFoncier('TITRE_FONCIER', 'Titre Foncier'),
  plan('PLAN', 'Plan'),
  photo('PHOTO', 'Photo');

  final String code;
  final String libelle;
  const TypeFichierProjet(this.code, this.libelle);

  static TypeFichierProjet depuis(String? code) => TypeFichierProjet.values
      .firstWhere((t) => t.code == code, orElse: () => TypeFichierProjet.photo);
}

/// Statut d'un dossier côté acquéreur.
enum StatutProjet {
  enEtude('EN_ETUDE'),
  enDiscussion('EN_DISCUSSION'),
  accepte('ACCEPTER'),
  refuse('REFUSER');

  final String code;
  const StatutProjet(this.code);

  static StatutProjet depuis(String? code) => StatutProjet.values
      .firstWhere((s) => s.code == code, orElse: () => StatutProjet.enEtude);
}

class FichierProjet {
  final int id;
  final TypeFichierProjet type;
  final String nomOriginal;

  const FichierProjet({required this.id, required this.type, required this.nomOriginal});

  factory FichierProjet.fromJson(Map<String, dynamic> json) => FichierProjet(
        id: (json['id'] as num).toInt(),
        type: TypeFichierProjet.depuis(json['type'] as String?),
        nomOriginal: json['nomOriginal'] as String? ?? 'Pièce jointe',
      );
}

/// Projet « Construire sur mon terrain » soumis par l'acquéreur.
class ProjetConstruction {
  final int id;
  final String numeroDossier;
  final StatutProjet statut;
  final int progression;
  final String? etapeAvancement;
  final String? commentaireAvancement;
  final String? motifRefus;
  final DateTime? dateDemande;
  final DateTime? dateDerniereMiseAJour;
  final String numeroTitreFoncier;
  final String? localisationTerrain;
  final double superficieTerrain;
  final String? description;
  final double? budgetEstime;
  final String? societeNom;
  final String? modeleLibelle;
  final String? modeleImageUrl;
  final String? maisonReferenceTitre;
  final String? maisonReferenceImageUrl;
  final bool modelePersonnalise;
  /// Questionnaire rempli par l'acquéreur (modèle personnalisé).
  final DescriptionMaison? maisonSouhaitee;

  /// Proposition de la société acceptée : termes de l'accord.
  final PropositionProjet? propositionRetenue;
  final List<FichierProjet> fichiers;

  /// L'acquéreur peut encore répondre aux propositions.
  bool get enCours => statut == StatutProjet.enEtude || statut == StatutProjet.enDiscussion;

  const ProjetConstruction({
    required this.id,
    required this.numeroDossier,
    required this.statut,
    required this.progression,
    required this.numeroTitreFoncier,
    required this.superficieTerrain,
    this.etapeAvancement,
    this.commentaireAvancement,
    this.motifRefus,
    this.dateDemande,
    this.dateDerniereMiseAJour,
    this.localisationTerrain,
    this.description,
    this.budgetEstime,
    this.societeNom,
    this.modeleLibelle,
    this.modeleImageUrl,
    this.maisonReferenceTitre,
    this.maisonReferenceImageUrl,
    this.modelePersonnalise = false,
    this.maisonSouhaitee,
    this.propositionRetenue,
    this.fichiers = const [],
  });

  String get libelleModele => modelePersonnalise
      ? 'Modèle personnalisé'
      : maisonReferenceTitre != null
          ? 'Comme « $maisonReferenceTitre »'
          : (modeleLibelle ?? 'Modèle du catalogue');

  factory ProjetConstruction.fromJson(Map<String, dynamic> json) {
    DateTime? date(String k) => DateTime.tryParse(json[k]?.toString() ?? '');
    return ProjetConstruction(
      id: (json['id'] as num).toInt(),
      numeroDossier: json['numeroDossier'] as String? ?? '',
      statut: StatutProjet.depuis(json['statut'] as String?),
      progression: (json['progression'] as num?)?.toInt() ?? 0,
      etapeAvancement: json['etapeAvancement'] as String?,
      commentaireAvancement: json['commentaireAvancement'] as String?,
      motifRefus: json['motifRefus'] as String?,
      dateDemande: date('dateDemande'),
      dateDerniereMiseAJour: date('dateDerniereMiseAJour'),
      numeroTitreFoncier: json['numeroTitreFoncier'] as String? ?? '',
      localisationTerrain: json['localisationTerrain'] as String?,
      superficieTerrain: (json['superficieTerrain'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      budgetEstime: (json['budgetEstime'] as num?)?.toDouble(),
      societeNom: json['societeNom'] as String?,
      modeleLibelle: json['modelMaisonLibeller'] as String?,
      modeleImageUrl: json['modelMaisonImageUrl'] as String?,
      maisonReferenceTitre: json['maisonReferenceTitre'] as String?,
      maisonReferenceImageUrl: json['maisonReferenceImageUrl'] as String?,
      modelePersonnalise: json['modelePersonnalise'] as bool? ?? false,
      maisonSouhaitee: json['maisonSouhaitee'] is Map<String, dynamic>
          ? DescriptionMaison.fromJson(json['maisonSouhaitee'] as Map<String, dynamic>)
          : null,
      propositionRetenue: json['propositionRetenue'] is Map<String, dynamic>
          ? PropositionProjet.fromJson(json['propositionRetenue'] as Map<String, dynamic>)
          : null,
      fichiers: ((json['fichiers'] as List?) ?? const [])
          .map((f) => FichierProjet.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
