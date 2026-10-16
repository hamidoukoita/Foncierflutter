import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import '../../controllers/champs_projet.dart';
import '../../controllers/soumission_controller.dart';
import 'entete_etape.dart';

/// Étape 4 : relecture du dossier avant envoi, avec un message libre pour le promoteur.
class EtapeRecapitulatif extends ConsumerWidget {
  final ChampsProjet champs;
  const EtapeRecapitulatif({super.key, required this.champs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etat = ref.watch(soumissionControllerProvider);
    final budget = ChampsProjet.nombre(champs.budget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EnteteEtape(
          titre: 'Vérifiez votre dossier',
          texte: 'Le promoteur étudie votre demande puis l’accepte ou la refuse. '
              'Vous suivrez l’avancement depuis votre accueil.',
        ),
        _Bloc(
          icone: Icons.business_rounded,
          titre: 'Promoteur',
          lignes: [etat.societe?.nom ?? '—'],
          onModifier: () => ref.read(soumissionControllerProvider.notifier).allerA(EtapeSoumission.societe),
        ),
        _Bloc(
          icone: Icons.landscape_outlined,
          titre: 'Terrain',
          lignes: [
            'TF ${champs.titreFoncier.text.trim()}',
            '${champs.superficie.text.trim()} m²${champs.localisation.text.trim().isEmpty ? '' : ' · ${champs.localisation.text.trim()}'}',
            if (budget != null) 'Budget : ${CurrencyFormatter.fcfa(budget)}',
          ],
          onModifier: () => ref.read(soumissionControllerProvider.notifier).allerA(EtapeSoumission.terrain),
        ),
        _Bloc(
          icone: Icons.home_outlined,
          titre: 'Maison',
          lignes: etat.modelePersonnalise
              ? [
                  'Modèle personnalisé',
                  champs.descriptionModele.text.trim(),
                ]
              : etat.maison != null
                  ? ['Comme la maison clé en main « ${etat.maison!.titre} »']
                  : [etat.modele?.libelle ?? '—'],
          onModifier: () => ref.read(soumissionControllerProvider.notifier).allerA(EtapeSoumission.modele),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Message au promoteur', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: champs.message,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Délais souhaités, contraintes, questions… (facultatif)'),
        ),
      ],
    );
  }
}

class _Bloc extends StatelessWidget {
  final IconData icone;
  final String titre;
  final List<String> lignes;
  final VoidCallback? onModifier;

  const _Bloc({required this.icone, required this.titre, required this.lignes, this.onModifier});

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
                for (final l in lignes.where((l) => l.isNotEmpty))
                  Text(l, maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyMedium),
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
