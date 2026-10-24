import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/montant_saisie.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/titre_foncier.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/titre_foncier_prefixe.dart';
import '../../controllers/champs_projet.dart';
import '../../controllers/soumission_controller.dart';
import 'entete_etape.dart';

/// Étape 2 : le terrain titré sur lequel construire.
class EtapeTerrain extends ConsumerWidget {
  final ChampsProjet champs;
  final GlobalKey<FormState> formKey;

  const EtapeTerrain({super.key, required this.champs, required this.formKey});

  static const _formes = {'STANDARD': 'Standard', 'ANGLE': 'D’angle', 'IRREGULIER': 'Irrégulier'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chiffres = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    final societe = ref.watch(soumissionControllerProvider.select((e) => e.societe));
    final minimum = societe?.budgetMinimumConstruction;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EnteteEtape(
            titre: 'Votre terrain',
            texte: 'Le promoteur vérifie le Titre Foncier avant d’étudier votre projet.',
          ),
          AppTextField(
            label: 'N° du Titre Foncier *',
            controller: champs.titreFoncier,
            hintText: '1024/Kati',
            prefixIcon: const TitreFoncierPrefixe(),
            validator: TitreFoncier.valider,
          ),
          const _Aide('Recopiez la référence inscrite sur votre Titre Foncier, après « TF- ».'),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Localisation',
            controller: champs.localisation,
            hintText: 'Quartier, commune…',
            prefixIcon: const Icon(Icons.place_outlined),
          ),
          const SizedBox(height: AppSpacing.md),
          _ChampNombre(
            label: 'Superficie totale du terrain (m²) *',
            controller: champs.superficie,
            formatters: chiffres,
            indice: '300',
            validator: (v) {
              final n = ChampsProjet.nombre(champs.superficie);
              return n == null || n <= 0 ? 'Superficie invalide' : null;
            },
          ),
          const _Aide('Telle qu’indiquée sur votre Titre Foncier.'),
          const SizedBox(height: AppSpacing.md),
          _ChampNombre(
            label: 'Votre budget (FCFA, facultatif)',
            controller: champs.budget,
            formatters: [MontantFormatter()],
            clavierEntier: true,
            indice: minimum == null ? '25 000 000' : MontantSaisie.grouper(minimum.round().toString()),
            validator: (_) {
              final budget = ChampsProjet.nombre(champs.budget);
              if (budget == null || minimum == null || budget >= minimum) return null;
              return 'Au moins ${CurrencyFormatter.fcfa(minimum)} chez ${societe!.nom}';
            },
          ),
          if (minimum != null) _BudgetMinimum(societe: societe!.nom, minimum: minimum),
          const _Aide('Une estimation, à titre indicatif : elle aide la société à vous faire une '
              'proposition adaptée et ne vous engage pas. Vous pouvez laisser ce champ vide.'),
          const SizedBox(height: AppSpacing.md),
          Text('Forme du terrain', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<String?>(
            valueListenable: champs.typeTerrain,
            builder: (_, valeur, __) => Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final MapEntry(key: code, value: libelle) in _formes.entries)
                  ChoiceChip(
                    label: Text(libelle),
                    selected: valeur == code,
                    selectedColor: AppColors.primaryOcreSoft,
                    onSelected: (oui) => champs.typeTerrain.value = oui ? code : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChampNombre extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<TextInputFormatter> formatters;
  final String? indice;
  final String? Function(String?)? validator;

  /// Montant en FCFA : clavier sans virgule.
  final bool clavierEntier;

  const _ChampNombre({
    required this.label,
    required this.controller,
    required this.formatters,
    this.indice,
    this.validator,
    this.clavierEntier = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: clavierEntier ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: formatters,
          validator: validator,
          decoration: InputDecoration(hintText: indice),
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/// Budget minimum de la société choisie, rappelé sous le champ budget.
class _BudgetMinimum extends StatelessWidget {
  final String societe;
  final double minimum;
  const _BudgetMinimum({required this.societe, required this.minimum});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
      decoration: const BoxDecoration(color: AppColors.primaryOcreSoft, borderRadius: AppRadius.radiusMd),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, size: 18, color: AppColors.primaryOcreDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlueAnthracite),
                children: [
                  TextSpan(text: 'Budget minimum chez $societe : '),
                  TextSpan(
                    text: CurrencyFormatter.fcfa(minimum),
                    style: const TextStyle(fontWeight: FontWeight.w800),
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

/// Texte d'aide sous un champ.
class _Aide extends StatelessWidget {
  final String texte;
  const _Aide(this.texte);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs + AppSpacing.xxs),
      child: Text(texte, style: AppTextStyles.bodySmall),
    );
  }
}
