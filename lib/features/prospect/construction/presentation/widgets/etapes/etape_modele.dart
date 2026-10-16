import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/providers/maisons_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/panorama_viewer_screen.dart';
import '../../../domain/modele_maison.dart';
import '../../../providers/construction_providers.dart';
import '../../controllers/champs_projet.dart';
import '../../controllers/soumission_controller.dart';
import '../carrousel_choix.dart';
import '../carte_choix_maison.dart';
import '../carte_selectionnable.dart';
import 'entete_etape.dart';

/// Étape 3 : un modèle du catalogue de la société, une de ses maisons clés en main comme
/// référence, ou la maison décrite par l'acquéreur. Modèles et maisons défilent en carrousel.
class EtapeModele extends ConsumerWidget {
  final ChampsProjet champs;
  final GlobalKey<FormState> formKey;

  const EtapeModele({super.key, required this.champs, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etat = ref.watch(soumissionControllerProvider);
    final controller = ref.read(soumissionControllerProvider.notifier);
    final societe = etat.societe!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnteteEtape(
          titre: 'Votre future maison',
          texte: 'Choisissez un modèle de ${societe.nom} adapté à votre terrain, '
              'une de ses maisons clés en main comme référence, ou décrivez la maison que vous souhaitez.',
        ),
        _ModelesDuCatalogue(societeId: societe.id, champs: champs),
        const SizedBox(height: AppSpacing.lg),
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
                  borderRadius: AppRadius.radiusMd,
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
                      Text('Décrivez la maison que vous souhaitez faire construire.',
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

/// Ouvre la visite 360° à partir des médias chargés pour le modèle ou la maison.
Future<void> _ouvrir360(BuildContext context, Future<List<MediaModel>> medias) async {
  try {
    final panoramas = (await medias).where((m) => m.isPanorama).toList();
    if (!context.mounted) return;
    if (panoramas.isEmpty) {
      AppSnackbar.info(context, 'Aucune vue 360° disponible.');
      return;
    }
    await PanoramaViewerScreen.show(context, panoramas);
  } catch (e) {
    if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
  }
}

/// Carrousel des modèles du catalogue, grisés s'ils ne conviennent pas au terrain saisi.
class _ModelesDuCatalogue extends ConsumerWidget {
  final int societeId;
  final ChampsProjet champs;
  const _ModelesDuCatalogue({required this.societeId, required this.champs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeles = ref.watch(modelesSocieteProvider(societeId));
    final choisi = ref.watch(soumissionControllerProvider.select((s) => s.modele));

    return modeles.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
      ),
      error: (e, _) => EmptyStateView(
        icon: Icons.cloud_off_rounded,
        title: 'Catalogue indisponible',
        message: ErrorHandler.messageOf(e),
        onRetry: () => ref.invalidate(modelesSocieteProvider(societeId)),
      ),
      data: (liste) {
        if (liste.isEmpty) {
          return Text('Cette société n’a pas encore publié de modèle.', style: AppTextStyles.bodySmall);
        }
        return CarrouselChoix(
          titre: 'Modèles du catalogue',
          nombre: liste.length,
          itemBuilder: (context, i) {
            final m = liste[i];
            final compatible = m.convientA(champs.superficieM2, champs.typeTerrain.value);
            return CarteChoixMaison(
              titre: m.libelle,
              imageUrl: m.imageUrl,
              caracteristiques: _caracteristiques(m),
              note: m.terrainRequis == null
                  ? null
                  : compatible
                      ? m.terrainRequis
                      : 'Non adapté à votre terrain · ${m.terrainRequis}',
              noteEnAlerte: !compatible,
              nombrePanoramas: m.nombrePanoramas,
              onVoir360: () => _ouvrir360(context, ref.read(mediasModeleProvider(m.id).future)),
              selectionnee: choisi?.id == m.id,
              active: compatible,
              onTap: () => ref.read(soumissionControllerProvider.notifier).choisirModele(m),
            );
          },
        );
      },
    );
  }

  static List<(IconData, String)> _caracteristiques(ModeleMaison m) => [
        if (m.nombreChambres != null) (Icons.bed_outlined, '${m.nombreChambres} ch.'),
        if (m.nombreSallesBain != null) (Icons.bathtub_outlined, '${m.nombreSallesBain} sdb'),
        if (m.surfaceConstruite != null) (Icons.square_foot_rounded, '${m.surfaceConstruite!.toStringAsFixed(0)} m²'),
      ];
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
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: CarrouselChoix(
        titre: 'Comme une maison clé en main',
        sousTitre: 'La société construit une maison semblable sur votre terrain.',
        nombre: maisons.length,
        itemBuilder: (context, i) {
          final m = maisons[i];
          return CarteChoixMaison(
            titre: m.titre,
            imageUrl: m.imageUrl,
            caracteristiques: [
              if (m.nombreChambres != null) (Icons.bed_outlined, '${m.nombreChambres} ch.'),
              if (m.surfaceHabitable != null)
                (Icons.square_foot_rounded, '${m.surfaceHabitable!.toStringAsFixed(0)} m²'),
            ],
            note: 'Prix de la maison : ${CurrencyFormatter.fcfaCompact(m.prix)}',
            nombrePanoramas: m.nombrePanoramas,
            onVoir360: () => _ouvrir360(context, ref.read(mediasBienProvider(m.id).future)),
            selectionnee: choisie?.id == m.id,
            onTap: () => ref.read(soumissionControllerProvider.notifier).choisirMaison(m),
          );
        },
      ),
    );
  }
}

class _ModelePersonnalise extends StatelessWidget {
  final ChampsProjet champs;
  final GlobalKey<FormState> formKey;
  const _ModelePersonnalise({required this.champs, required this.formKey});

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
