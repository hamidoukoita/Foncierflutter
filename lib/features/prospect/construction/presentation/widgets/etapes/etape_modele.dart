import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../../domain/projet_construction.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/annonce_artwork.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/providers/maisons_providers.dart';
import '../../../domain/soumission_projet.dart';
import '../../../providers/construction_providers.dart';
import '../../controllers/champs_projet.dart';
import '../../controllers/soumission_controller.dart';
import '../carte_selectionnable.dart';
import '../modele_card.dart';
import '../pieces_jointes_field.dart';
import 'entete_etape.dart';

/// Étape 3 : un modèle du catalogue de la société, ou la maison décrite par l'acquéreur.
class EtapeModele extends ConsumerWidget {
  final ChampsProjet champs;
  final GlobalKey<FormState> formKey;

  const EtapeModele({super.key, required this.champs, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etat = ref.watch(soumissionControllerProvider);
    final controller = ref.read(soumissionControllerProvider.notifier);
    final societe = etat.societe!;
    final modeles = ref.watch(modelesSocieteProvider(societe.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnteteEtape(
          titre: 'Votre future maison',
          texte: 'Choisissez un modèle de ${societe.nom} adapté à votre terrain, '
              'une de ses maisons clés en main comme référence, ou décrivez la maison que vous souhaitez.',
        ),
        modeles.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
          ),
          error: (e, _) => EmptyStateView(
            icon: Icons.cloud_off_rounded,
            title: 'Catalogue indisponible',
            message: ErrorHandler.messageOf(e),
            onRetry: () => ref.invalidate(modelesSocieteProvider(societe.id)),
          ),
          data: (liste) => Column(
            children: [
              if (liste.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text('Cette société n’a pas encore publié de modèle.',
                      style: AppTextStyles.bodySmall),
                ),
              for (final m in liste)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xxs),
                  child: ModeleCard(
                    modele: m,
                    selectionne: etat.modele?.id == m.id,
                    compatible: m.convientA(champs.superficieM2, champs.typeTerrain.value),
                    onTap: () => controller.choisirModele(m),
                  ),
                ),
            ],
          ),
        ),
        _MaisonsDeReference(societeId: societe.id),
        CarteSelectionnable(
          selectionnee: etat.modelePersonnalise,
          onTap: controller.choisirModelePersonnalise,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueAnthracite.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.draw_outlined, color: AppColors.primaryBlueAnthracite),
              ),
              const SizedBox(width: AppSpacing.md - AppSpacing.xs),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proposer mon propre modèle', style: AppTextStyles.cardTitle),
                      Text('Décrivez la maison, joignez vos plans ou photos d’inspiration.',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (etat.modelePersonnalise) ...[
          const SizedBox(height: AppSpacing.md),
          _ModelePersonnalise(champs: champs, formKey: formKey),
        ],
      ],
    );
  }
}

class _ModelePersonnalise extends ConsumerWidget {
  final ChampsProjet champs;
  final GlobalKey<FormState> formKey;
  const _ModelePersonnalise({required this.champs, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(soumissionControllerProvider.notifier);
    final pieces = ref.watch(soumissionControllerProvider
        .select((s) => s.piecesDeType({TypeFichierProjet.plan, TypeFichierProjet.photo})));
    final entiers = [FilteringTextInputFormatter.digitsOnly];

    InputDecoration deco(String indice) => InputDecoration(hintText: indice);
    Widget libelle(String t) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(t, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        );

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          libelle('Description de la maison *'),
          TextFormField(
            controller: champs.descriptionModele,
            minLines: 3,
            maxLines: 6,
            maxLength: 3000,
            decoration: deco('Style, nombre de niveaux, pièces, terrasse, garage…'),
            validator: (v) => (v ?? '').trim().length < 10 ? 'Décrivez la maison en quelques phrases' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final (titre, ctrl, indice) in [
                ('Chambres', champs.chambres, '3'),
                ('Salles de bain', champs.sallesBain, '2'),
                ('Surface (m²)', champs.surfaceConstruite, '150'),
              ]) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      libelle(titre),
                      TextFormField(
                        controller: ctrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: entiers,
                        decoration: deco(indice),
                      ),
                    ],
                  ),
                ),
                if (titre != 'Surface (m²)') const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PiecesJointesField(
            titre: 'Plans et photos d’inspiration',
            aide: 'Facultatif : plan d’architecte, croquis, photos de maisons qui vous plaisent.',
            type: TypeFichierProjet.plan,
            pieces: pieces,
            // Les PDF sont des plans, les images des photos d'inspiration.
            onAjout: (nouvelles) => controller.ajouterPieces([
              for (final p in nouvelles)
                p.fichier.extension?.toLowerCase() == 'pdf'
                    ? p
                    : PieceAJoindre(p.fichier, TypeFichierProjet.photo),
            ]),
            onRetrait: controller.retirerPiece,
          ),
        ],
      ),
    );
  }
}

/// Maisons clés en main de la société, proposées comme référence (« une maison comme celle-ci »).
class _MaisonsDeReference extends ConsumerWidget {
  final int societeId;
  const _MaisonsDeReference({required this.societeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maisons = ref.watch(maisonsSocieteProvider(societeId)).valueOrNull ?? const [];
    final choisie = ref.watch(soumissionControllerProvider.select((s) => s.maison));
    if (maisons.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Text('Comme une maison clé en main',
                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
          ),
          for (final m in maisons)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xxs),
              child: CarteSelectionnable(
                selectionnee: choisie?.id == m.id,
                onTap: () => ref.read(soumissionControllerProvider.notifier).choisirMaison(m),
                child: Row(
                  children: [
                    AnnonceArtwork(imageUrl: m.imageUrl, estProgramme: false, taille: 64, rayon: AppRadius.radiusMd),
                    const SizedBox(width: AppSpacing.md - AppSpacing.xs),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.titre, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle),
                            Text(
                              [
                                if (m.nombreChambres != null) '${m.nombreChambres} ch.',
                                if (m.surfaceHabitable != null) '${m.surfaceHabitable!.toStringAsFixed(0)} m²',
                                CurrencyFormatter.fcfaCompact(m.prix),
                              ].join(' · '),
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
