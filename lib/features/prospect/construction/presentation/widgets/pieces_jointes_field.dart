import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import '../../domain/projet_construction.dart';
import '../../domain/soumission_projet.dart';

/// Sélection de pièces (PDF ou images) d'un type donné, avec la liste de celles déjà choisies.
class PiecesJointesField extends StatelessWidget {
  final String titre;
  final String aide;
  final TypeFichierProjet type;
  final List<PieceAJoindre> pieces;
  final ValueChanged<List<PieceAJoindre>> onAjout;
  final ValueChanged<PieceAJoindre> onRetrait;

  static const _extensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];
  static const _tailleMax = 15 * 1024 * 1024;

  const PiecesJointesField({
    super.key,
    required this.titre,
    required this.aide,
    required this.type,
    required this.pieces,
    required this.onAjout,
    required this.onRetrait,
  });

  Future<void> _choisir(BuildContext context) async {
    final resultat = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensions,
      allowMultiple: true,
    );
    if (resultat == null) return;
    final retenus = resultat.files.where((f) => f.size <= _tailleMax).toList();
    if (retenus.length < resultat.files.length && context.mounted) {
      AppSnackbar.error(context, 'Fichier ignoré : 15 Mo maximum par pièce.');
    }
    onAjout(retenus.map((f) => PieceAJoindre(f, type)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xxs),
        Text(aide, style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        for (final piece in pieces)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  piece.fichier.extension?.toLowerCase() == 'pdf'
                      ? Icons.picture_as_pdf_outlined
                      : Icons.image_outlined,
                  color: AppColors.primaryOcre,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(piece.fichier.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyMedium),
                ),
                IconButton(
                  tooltip: 'Retirer',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                  onPressed: () => onRetrait(piece),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => _choisir(context),
          icon: const Icon(Icons.attach_file_rounded, size: 18),
          label: Text(pieces.isEmpty ? 'Joindre un fichier' : 'Ajouter un autre fichier'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlueAnthracite,
            side: const BorderSide(color: AppColors.borderLight),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        ),
      ],
    );
  }
}
