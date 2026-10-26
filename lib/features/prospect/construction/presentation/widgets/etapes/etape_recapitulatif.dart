import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/titre_foncier.dart';
import '../../controllers/champs_projet.dart';
import '../../controllers/soumission_controller.dart';
import '../description_maison_chips.dart';
import 'entete_etape.dart';

/// Étape 4 : relecture complète du dossier avant envoi, avec un dernier mot pour la société.
class EtapeRecapitulatif extends ConsumerWidget {
  final ChampsProjet champs;
  const EtapeRecapitulatif({super.key, required this.champs});

  static const _formes = {'STANDARD': 'Standard', 'ANGLE': 'D’angle', 'IRREGULIER': 'Irrégulier'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etat = ref.watch(soumissionControllerProvider);
    final controller = ref.read(soumissionControllerProvider.notifier);
    final budget = ChampsProjet.nombre(champs.budget);
    final localisation = champs.localisation.text.trim();
    final forme = _formes[champs.typeTerrain.value];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EnteteEtape(
          titre: 'Vérifiez votre dossier',
          texte: 'Voici tout ce que la société va recevoir. Elle pourra vous poser des questions, '
              'vous faire des propositions, accepter ou refuser votre projet.',
        ),
        _Bloc(
          icone: Icons.business_rounded,
          titre: 'Société',
          onModifier: () => controller.allerA(EtapeSoumission.societe),
          child: _Lignes([etat.societe?.nom ?? '—']),
        ),
        _Bloc(
          icone: Icons.landscape_outlined,
          titre: 'Terrain',
          onModifier: () => controller.allerA(EtapeSoumission.terrain),
          child: _Lignes([
            'Titre Foncier : ${TitreFoncier.complet(champs.titreFoncier.text)}',
            'Superficie totale : ${champs.superficie.text.trim()} m²',
            if (localisation.isNotEmpty) 'Localisation : $localisation',
            if (forme != null) 'Forme : $forme',
            if (budget != null) 'Votre budget (indicatif) : ${CurrencyFormatter.fcfa(budget)}',
          ]),
        ),
        _Bloc(
          icone: Icons.home_outlined,
          titre: 'Maison',
          onModifier: () => controller.allerA(EtapeSoumission.modele),
          child: etat.modelePersonnalise
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Lignes(['Votre propre modèle']),
                    const SizedBox(height: AppSpacing.sm),
                    DescriptionMaisonChips(description: champs.maisonSouhaitee),
                  ],
                )
              : _Lignes([
                  etat.maison != null
                      ? 'Comme la maison clé en main « ${etat.maison!.titre} »'
                      : 'Modèle du catalogue : ${etat.modele?.libelle ?? '—'}',
                ]),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Voulez-vous ajouter quelque chose ?', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xs),
        Text('Facultatif : vos délais, une contrainte du terrain, une question pour la société…',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: champs.message,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Votre message à la société'),
        ),
      ],
    );
  }
}

class _Lignes extends StatelessWidget {
  final List<String> lignes;
  const _Lignes(this.lignes);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final l in lignes.where((l) => l.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Text(l, style: AppTextStyles.bodyMedium),
          ),
      ],
    );
  }
}

class _Bloc extends StatelessWidget {
  final IconData icone;
  final String titre;
  final Widget child;
  final VoidCallback? onModifier;

  const _Bloc({required this.icone, required this.titre, required this.child, this.onModifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xxs),
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: AppColors.primaryOcre),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre.toUpperCase(), style: AppTextStyles.overline),
                const SizedBox(height: AppSpacing.xxs),
                child,
              ],
            ),
          ),
          if (onModifier != null)
            TextButton(onPressed: onModifier, child: const Text('Modifier')),
        ],
      ),
    );
  }
}
