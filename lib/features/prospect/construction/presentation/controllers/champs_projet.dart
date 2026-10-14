import 'package:flutter/widgets.dart';
import '../../domain/soumission_projet.dart';

/// Champs texte du formulaire, partagés entre les étapes et libérés avec l'écran.
class ChampsProjet {
  final titreFoncier = TextEditingController();
  final localisation = TextEditingController();
  final superficie = TextEditingController();
  final budget = TextEditingController();
  final message = TextEditingController();
  final descriptionModele = TextEditingController();
  final chambres = TextEditingController();
  final sallesBain = TextEditingController();
  final surfaceConstruite = TextEditingController();

  /// Forme du terrain, comparée au « type de terrain compatible » des modèles.
  final typeTerrain = ValueNotifier<String?>(null);

  static double? nombre(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(' ', '').replaceAll(',', '.'));

  static String? texte(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  double? get superficieM2 => nombre(superficie);

  SoumissionProjet versSoumission({required int societeId, int? modeleId, int? maisonId}) {
    return SoumissionProjet(
      societeId: societeId,
      modeleId: modeleId,
      maisonId: maisonId,
      numeroTitreFoncier: titreFoncier.text.trim(),
      localisationTerrain: texte(localisation),
      superficieTerrain: superficieM2 ?? 0,
      typeTerrain: typeTerrain.value,
      budgetEstime: nombre(budget),
      description: texte(message),
      descriptionModelePersonnalise: texte(descriptionModele),
      nombreChambres: nombre(chambres)?.round(),
      nombreSallesBain: nombre(sallesBain)?.round(),
      surfaceConstruite: nombre(surfaceConstruite),
    );
  }

  void dispose() {
    for (final c in [
      titreFoncier, localisation, superficie, budget, message,
      descriptionModele, chambres, sallesBain, surfaceConstruite,
    ]) {
      c.dispose();
    }
    typeTerrain.dispose();
  }
}
