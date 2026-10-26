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
  final bool envoi;

  const SoumissionState({
    this.etape = EtapeSoumission.societe,
    this.societe,
    this.modele,
    this.maison,
    this.modelePersonnalise = false,
    this.envoi = false,
  });

  bool get maisonChoisie => modele != null || maison != null || modelePersonnalise;

  SoumissionState copyWith({
    EtapeSoumission? etape,
    SocietePromotrice? societe,
    ModeleMaison? Function()? modele,
    MaisonCleEnMain? Function()? maison,
    bool? modelePersonnalise,
    bool? envoi,
  }) {
    return SoumissionState(
      etape: etape ?? this.etape,
      societe: societe ?? this.societe,
      modele: modele != null ? modele() : this.modele,
      maison: maison != null ? maison() : this.maison,
      modelePersonnalise: modelePersonnalise ?? this.modelePersonnalise,
      envoi: envoi ?? this.envoi,
    );
  }
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

  /// Remplace la société provisoire par sa fiche complète, sans changer d'étape.
  void completerSociete(SocietePromotrice societe) {
    if (state.societe?.id == societe.id) state = state.copyWith(societe: societe);
  }

  /// Crée le dossier de construction.
  Future<ProjetConstruction> soumettre(SoumissionProjet soumission) async {
    state = state.copyWith(envoi: true);
    try {
      final projet = await ref.read(projetConstructionRepositoryProvider).soumettre(soumission);
      ref.invalidate(mesProjetsProvider);
      return projet;
    } finally {
      state = state.copyWith(envoi: false);
    }
  }
}

final soumissionControllerProvider =
    AutoDisposeNotifierProvider<SoumissionController, SoumissionState>(SoumissionController.new);
