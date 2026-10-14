import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/back_title_header.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';
import '../../construction_routes.dart';
import '../../domain/societe_promotrice.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/domain/maison_cle_en_main.dart';
import '../controllers/champs_projet.dart';
import '../controllers/soumission_controller.dart';
import '../widgets/etapes/etape_modele.dart';
import '../widgets/etapes/etape_recapitulatif.dart';
import '../widgets/etapes/etape_societe.dart';
import '../widgets/etapes/etape_terrain.dart';
import '../widgets/etapes_indicateur.dart';

/// « Soumettre mon projet » : société → terrain → maison → envoi.
class SoumettreProjetScreen extends ConsumerStatefulWidget {
  /// Maison clé en main d'où vient l'acquéreur : sa société et sa référence sont présélectionnées.
  final MaisonCleEnMain? maisonDeReference;

  const SoumettreProjetScreen({super.key, this.maisonDeReference});

  @override
  ConsumerState<SoumettreProjetScreen> createState() => _SoumettreProjetScreenState();
}

class _SoumettreProjetScreenState extends ConsumerState<SoumettreProjetScreen> {
  final _champs = ChampsProjet();
  final _formTerrain = GlobalKey<FormState>();
  final _formModele = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final maison = widget.maisonDeReference;
    if (maison != null && maison.societeId != null) {
      // Après la première image : un provider ne se modifie pas pendant la construction de l'arbre.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.preselectionner(
          SocietePromotrice(id: maison.societeId!, nom: maison.societeNom ?? 'Promoteur'),
          maison,
        );
      });
    }
  }

  @override
  void dispose() {
    _champs.dispose();
    super.dispose();
  }

  SoumissionController get _controller => ref.read(soumissionControllerProvider.notifier);

  /// Contrôle de l'étape courante ; renvoie un message d'erreur ou null.
  String? _verifier(SoumissionState etat) {
    switch (etat.etape) {
      case EtapeSoumission.societe:
        return etat.societe == null ? 'Choisissez une société promotrice.' : null;
      case EtapeSoumission.terrain:
        return _formTerrain.currentState?.validate() == false ? 'Complétez les informations du terrain.' : null;
      case EtapeSoumission.modele:
        if (!etat.maisonChoisie) return 'Choisissez un modèle, une maison clé en main ou proposez le vôtre.';
        if (etat.modelePersonnalise) {
          return _formModele.currentState?.validate() == false ? 'Décrivez la maison souhaitée.' : null;
        }
        if (etat.maison != null) return null;
        return etat.modele!.convientA(_champs.superficieM2, _champs.typeTerrain.value)
            ? null
            : 'Ce modèle ne convient pas à votre terrain.';
      case EtapeSoumission.recapitulatif:
        return null;
    }
  }

  Future<void> _suivant(SoumissionState etat) async {
    FocusScope.of(context).unfocus();
    final erreur = _verifier(etat);
    if (erreur != null) {
      AppSnackbar.error(context, erreur);
      return;
    }
    if (etat.etape != EtapeSoumission.recapitulatif) {
      _controller.allerA(EtapeSoumission.values[etat.etape.index + 1]);
      return;
    }
    try {
      final resultat = await _controller.soumettre(
        _champs.versSoumission(
            societeId: etat.societe!.id, modeleId: etat.modele?.id, maisonId: etat.maison?.id),
      );
      if (!mounted) return;
      if (resultat.piecesEnEchec > 0) {
        AppSnackbar.error(context,
            'Projet envoyé, mais ${resultat.piecesEnEchec} pièce(s) n’ont pas pu être jointes.');
      } else {
        AppSnackbar.success(context, 'Projet envoyé à ${etat.societe!.nom}.');
      }
      context.pushReplacement(ConstructionRoutes.detail(resultat.projet.id));
    } catch (e) {
      if (mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
    }
  }

  void _precedent(SoumissionState etat) {
    if (etat.etape == EtapeSoumission.societe) {
      context.pop();
    } else {
      _controller.allerA(EtapeSoumission.values[etat.etape.index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final etat = ref.watch(soumissionControllerProvider);
    final derniere = etat.etape == EtapeSoumission.recapitulatif;

    return PopScope(
      canPop: etat.etape == EtapeSoumission.societe && !etat.envoi,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !etat.envoi) _precedent(etat);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal, AppSpacing.md, AppSpacing.pageHorizontal, AppSpacing.md),
                child: Column(
                  children: [
                    const BackTitleHeader(title: 'Construire sur mon terrain'),
                    const SizedBox(height: AppSpacing.lg),
                    EtapesIndicateur(courante: etat.etape),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal, AppSpacing.sm, AppSpacing.pageHorizontal, AppSpacing.xl),
                  child: switch (etat.etape) {
                    EtapeSoumission.societe => const EtapeSociete(),
                    EtapeSoumission.terrain => EtapeTerrain(champs: _champs, formKey: _formTerrain),
                    EtapeSoumission.modele => EtapeModele(champs: _champs, formKey: _formModele),
                    EtapeSoumission.recapitulatif => EtapeRecapitulatif(champs: _champs),
                  },
                ),
              ),
              _BarreActions(
                derniere: derniere,
                envoi: etat.envoi,
                onPrecedent: etat.etape == EtapeSoumission.societe ? null : () => _precedent(etat),
                onSuivant: () => _suivant(etat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarreActions extends StatelessWidget {
  final bool derniere;
  final bool envoi;
  final VoidCallback? onPrecedent;
  final VoidCallback onSuivant;

  const _BarreActions({required this.derniere, required this.envoi, required this.onPrecedent, required this.onSuivant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, AppSpacing.sm + AppSpacing.xxs, AppSpacing.pageHorizontal, AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          if (onPrecedent != null) ...[
            Expanded(
              child: PrimaryButton(text: 'Retour', isSecondary: true, onPressed: envoi ? null : onPrecedent),
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
          ],
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: derniere ? 'Envoyer mon projet' : 'Continuer',
              icon: derniere ? Icons.send_rounded : Icons.arrow_forward_rounded,
              isLoading: envoi,
              onPressed: envoi ? null : onSuivant,
            ),
          ),
        ],
      ),
    );
  }
}
