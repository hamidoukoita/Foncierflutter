import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/modele_maison.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/domain/maison_cle_en_main.dart';
import '../../domain/projet_construction.dart';
import '../../domain/societe_promotrice.dart';
import '../../domain/soumission_projet.dart';
import '../../providers/construction_providers.dart';

/// Étapes du formulaire « Soumettre mon projet ».
enum EtapeSoumission {
  societe('Société'),
  terrain('Terrain'),
  modele('Maison'),
  recapitulatif('Envoi');

  final String libelle;
  const EtapeSoumission(this.libelle);
}

class SoumissionState {
  final EtapeSoumission etape;
  final SocietePromotrice? societe;
  final ModeleMaison? modele;
  final MaisonCleEnMain? maison;
  final bool modelePersonnalise;
  final List<PieceAJoindre> pieces;
  final bool envoi;

  const SoumissionState({
    this.etape = EtapeSoumission.societe,
    this.societe,
    this.modele,
    this.maison,
    this.modelePersonnalise = false,
    this.pieces = const [],
    this.envoi = false,
  });

  bool get maisonChoisie => modele != null || maison != null || modelePersonnalise;

  List<PieceAJoindre> piecesDeType(Set<TypeFichierProjet> types) =>
      pieces.where((p) => types.contains(p.type)).toList();

  SoumissionState copyWith({
    EtapeSoumission? etape,
    SocietePromotrice? societe,
    ModeleMaison? Function()? modele,
    MaisonCleEnMain? Function()? maison,
    bool? modelePersonnalise,
    List<PieceAJoindre>? pieces,
    bool? envoi,
  }) {
    return SoumissionState(
      etape: etape ?? this.etape,
      societe: societe ?? this.societe,
      modele: modele != null ? modele() : this.modele,
      maison: maison != null ? maison() : this.maison,
      modelePersonnalise: modelePersonnalise ?? this.modelePersonnalise,
      pieces: pieces ?? this.pieces,
      envoi: envoi ?? this.envoi,
    );
  }
}

/// Résultat de l'envoi : le dossier créé et les pièces qui n'ont pas pu partir.
class ResultatSoumission {
  final ProjetConstruction projet;
  final int piecesEnEchec;
  const ResultatSoumission(this.projet, this.piecesEnEchec);
}

class SoumissionController extends AutoDisposeNotifier<SoumissionState> {
  @override
  SoumissionState build() => const SoumissionState();

  void allerA(EtapeSoumission etape) => state = state.copyWith(etape: etape);

  void choisirSociete(SocietePromotrice societe) {
    // Le catalogue change avec la société : le modèle choisi n'est plus valable.
    final memeSociete = state.societe?.id == societe.id;
    state = state.copyWith(
      societe: societe,
      modele: memeSociete ? null : () => null,
      maison: memeSociete ? null : () => null,
    );
  }

  void choisirModele(ModeleMaison modele) =>
      state = state.copyWith(modele: () => modele, maison: () => null, modelePersonnalise: false);

  void choisirMaison(MaisonCleEnMain maison) =>
      state = state.copyWith(maison: () => maison, modele: () => null, modelePersonnalise: false);

  void choisirModelePersonnalise() =>
      state = state.copyWith(modele: () => null, maison: () => null, modelePersonnalise: true);

  /// Arrivée depuis la fiche d'une maison : société et référence déjà connues, on commence par le terrain.
  void preselectionner(SocietePromotrice societe, MaisonCleEnMain maison) {
    state = SoumissionState(etape: EtapeSoumission.terrain, societe: societe, maison: maison);
  }

  void ajouterPieces(List<PieceAJoindre> pieces) =>
      state = state.copyWith(pieces: [...state.pieces, ...pieces]);

  void retirerPiece(PieceAJoindre piece) =>
      state = state.copyWith(pieces: state.pieces.where((p) => p != piece).toList());

  /// Crée le dossier puis envoie les pièces jointes une à une.
  Future<ResultatSoumission> soumettre(SoumissionProjet soumission) async {
    state = state.copyWith(envoi: true);
    try {
      final repo = ref.read(projetConstructionRepositoryProvider);
      final projet = await repo.soumettre(soumission);
      // Les plans et photos d'un modèle du catalogue n'ont plus d'objet.
      final pieces = state.modelePersonnalise
          ? state.pieces
          : state.piecesDeType({TypeFichierProjet.titreFoncier});
      var echecs = 0;
      for (final piece in pieces) {
        try {
          await repo.joindre(projet.id, piece);
        } catch (_) {
          echecs++;
        }
      }
      ref.invalidate(mesProjetsProvider);
      return ResultatSoumission(projet, echecs);
    } finally {
      state = state.copyWith(envoi: false);
    }
  }
}

final soumissionControllerProvider =
    AutoDisposeNotifierProvider<SoumissionController, SoumissionState>(SoumissionController.new);
