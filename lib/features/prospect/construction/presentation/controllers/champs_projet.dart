import 'package:flutter/widgets.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/titre_foncier.dart';
import '../../domain/description_maison.dart';
import '../../domain/soumission_projet.dart';

/// Champs texte du formulaire, partagés entre les étapes et libérés avec l'écran.
class ChampsProjet {
  final titreFoncier = TextEditingController();
  final localisation = TextEditingController();
  final superficie = TextEditingController();
  final budget = TextEditingController();
  final message = TextEditingController();

  /// Précisions libres sur la maison personnalisée, en complément du questionnaire.
  final precisionsMaison = TextEditingController();

  /// Réponses au questionnaire de la maison personnalisée.
  final souhaits = ValueNotifier<DescriptionMaison>(DescriptionMaison.parDefaut);

  /// Forme du terrain, comparée au « type de terrain compatible » des modèles.
  final typeTerrain = ValueNotifier<String?>(null);

  static double? nombre(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(' ', '').replaceAll(',', '.'));

  static String? texte(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  double? get superficieM2 => nombre(superficie);

  DescriptionMaison get maisonSouhaitee => souhaits.value.avecPrecisions(precisionsMaison.text);

  SoumissionProjet versSoumission({required int societeId, int? modeleId, int? maisonId}) {
    return SoumissionProjet(
      societeId: societeId,
      modeleId: modeleId,
      maisonId: maisonId,
      numeroTitreFoncier: TitreFoncier.complet(titreFoncier.text),
      localisationTerrain: texte(localisation),
      superficieTerrain: superficieM2 ?? 0,
      typeTerrain: typeTerrain.value,
      budgetEstime: nombre(budget),
      description: texte(message),
      maisonSouhaitee: maisonSouhaitee,
    );
  }

  void dispose() {
    for (final c in [
      titreFoncier, localisation, superficie, budget, message, precisionsMaison,
    ]) {
      c.dispose();
    }
    typeTerrain.dispose();
    souhaits.dispose();
  }
}
