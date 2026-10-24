import 'description_maison.dart';

/// Données saisies dans le formulaire « Soumettre mon projet ».
class SoumissionProjet {
  final int societeId;
  final int? modeleId;
  /// Maison clé en main de la société prise comme référence.
  final int? maisonId;
  final String numeroTitreFoncier;
  final String? localisationTerrain;
  final double superficieTerrain;
  final String? typeTerrain;
  final double? budgetEstime;
  final String? description;

  /// Questionnaire de la maison souhaitée, envoyé seulement pour un modèle personnalisé.
  final DescriptionMaison? maisonSouhaitee;

  const SoumissionProjet({
    required this.societeId,
    required this.numeroTitreFoncier,
    required this.superficieTerrain,
    this.modeleId,
    this.maisonId,
    this.localisationTerrain,
    this.typeTerrain,
    this.budgetEstime,
    this.description,
    this.maisonSouhaitee,
  });

  bool get estPersonnalise => modeleId == null && maisonId == null;

  Map<String, dynamic> toJson() => {
        'societeId': societeId,
        if (modeleId != null) 'modelMaisonId': modeleId,
        if (maisonId != null) 'maisonCleEnMainId': maisonId,
        'numeroTitreFoncier': numeroTitreFoncier,
        if (localisationTerrain != null) 'localisationTerrain': localisationTerrain,
        'superficieTerrain': superficieTerrain,
        if (typeTerrain != null) 'typeTerrain': typeTerrain,
        if (budgetEstime != null) 'budgetEstime': budgetEstime,
        if (description != null) 'description': description,
        if (estPersonnalise && maisonSouhaitee != null) 'maisonSouhaitee': maisonSouhaitee!.toJson(),
      };
}
