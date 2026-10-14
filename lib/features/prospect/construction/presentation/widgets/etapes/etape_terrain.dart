import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import '../../../domain/projet_construction.dart';
import '../../controllers/champs_projet.dart';
import '../../controllers/soumission_controller.dart';
import '../pieces_jointes_field.dart';
import 'entete_etape.dart';

/// Étape 2 : le terrain titré sur lequel construire.
class EtapeTerrain extends ConsumerWidget {
  final ChampsProjet champs;
  final GlobalKey<FormState> formKey;

  const EtapeTerrain({super.key, required this.champs, required this.formKey});

  static const _formes = {'STANDARD': 'Standard', 'ANGLE': 'D’angle', 'IRREGULIER': 'Irrégulier'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieces = ref.watch(soumissionControllerProvider
        .select((s) => s.piecesDeType({TypeFichierProjet.titreFoncier})));
    final controller = ref.read(soumissionControllerProvider.notifier);
    final chiffres = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

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
            hintText: 'Ex. TF 1024 / Kati',
            prefixIcon: const Icon(Icons.verified_outlined),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Le numéro du Titre Foncier est obligatoire' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Localisation',
            controller: champs.localisation,
            hintText: 'Quartier, commune…',
            prefixIcon: const Icon(Icons.place_outlined),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ChampNombre(
                  label: 'Superficie (m²) *',
                  controller: champs.superficie,
                  formatters: chiffres,
                  validator: (v) {
                    final n = ChampsProjet.nombre(champs.superficie);
                    return n == null || n <= 0 ? 'Superficie invalide' : null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
              Expanded(
                child: _ChampNombre(
                  label: 'Budget (FCFA)',
                  controller: champs.budget,
                  formatters: chiffres,
                ),
              ),
            ],
          ),
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
          const SizedBox(height: AppSpacing.lg),
          PiecesJointesField(
            titre: 'Copie du Titre Foncier',
            aide: 'Recommandé : PDF ou photo lisible, 15 Mo maximum.',
            type: TypeFichierProjet.titreFoncier,
            pieces: pieces,
            onAjout: controller.ajouterPieces,
            onRetrait: controller.retirerPiece,
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
  final String? Function(String?)? validator;

  const _ChampNombre({required this.label, required this.controller, required this.formatters, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: formatters,
          validator: validator,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
