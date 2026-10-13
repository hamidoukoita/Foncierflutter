import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';

/// Annonce de l'accueil : une cité (avec prix de départ) ou une parcelle individuelle.
class AnnonceAccueil {
  final ProgrammeFoncier? programme;
  final BienFoncierModel? bien;
  final double? prixDepart;

  const AnnonceAccueil.programme(ProgrammeFoncier this.programme,
      {this.prixDepart})
      : bien = null;

  const AnnonceAccueil.bien(BienFoncierModel this.bien)
      : programme = null,
        prixDepart = null;

  bool get estProgramme => programme != null;

  /// Prix affiché : prix de départ d'une cité ou prix de la parcelle.
  double? get prix => programme != null ? prixDepart : bien!.prix;
}

/// Sélection des annonces mises en avant sur l'accueil.
class AnnoncesAccueil {
  AnnoncesAccueil._();

  static const int _nombreMaximum = 4;

  static bool estLot(BienFoncierModel bien) {
    final type = (bien.typeBien ?? '').toUpperCase();
    return type.contains('LOT') ||
        bien.numeroLot != null ||
        bien.programmeId != null;
  }

  static bool estDisponible(String statut) {
    final s = statut.trim().toUpperCase();
    return s == 'DISPONIBLE' || s == 'LIBRE' || s == 'AVAILABLE';
  }

  /// Cités disponibles puis parcelles individuelles disponibles.
  static List<AnnonceAccueil> recentes(
    List<ProgrammeFoncier> programmes,
    List<BienFoncierModel> catalogue,
  ) {
    return [
      for (final p in programmes
          .where((p) => (p.statut ?? '').trim().toUpperCase() == 'DISPONIBLE'))
        AnnonceAccueil.programme(p, prixDepart: _prixDepart(p, catalogue)),
      for (final b
          in catalogue.where((b) => !estLot(b) && estDisponible(b.statut)))
        AnnonceAccueil.bien(b),
    ].take(_nombreMaximum).toList();
  }

  /// Prix du lot disponible le moins cher de la cité.
  static double? _prixDepart(
      ProgrammeFoncier programme, List<BienFoncierModel> catalogue) {
    final prix = catalogue
        .where((b) =>
            estLot(b) &&
            estDisponible(b.statut) &&
            b.prix > 0 &&
            (b.programmeId == programme.id ||
                (b.programmeNom ?? '').trim().toLowerCase() ==
                    programme.nom.trim().toLowerCase()))
        .map((b) => b.prix)
        .toList()
      ..sort();
    return prix.isEmpty ? null : prix.first;
  }
}
