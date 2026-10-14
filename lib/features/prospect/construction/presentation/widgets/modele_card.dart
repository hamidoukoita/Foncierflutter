import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/annonce_artwork.dart';
import '../../domain/modele_maison.dart';
import 'carte_selectionnable.dart';

/// Modèle du catalogue de la société, grisé s'il ne convient pas à la superficie du terrain.
class ModeleCard extends StatelessWidget {
  final ModeleMaison modele;
  final bool selectionne;
  final bool compatible;
  final VoidCallback onTap;

  const ModeleCard({
    super.key,
    required this.modele,
    required this.selectionne,
    required this.compatible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final caracteristiques = [
      if (modele.nombreChambres != null) (Icons.bed_outlined, '${modele.nombreChambres} ch.'),
      if (modele.nombreSallesBain != null) (Icons.bathtub_outlined, '${modele.nombreSallesBain} sdb'),
      if (modele.surfaceConstruite != null)
        (Icons.square_foot_rounded, '${modele.surfaceConstruite!.toStringAsFixed(0)} m²'),
    ];
    return CarteSelectionnable(
      selectionnee: selectionne,
      active: compatible,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnnonceArtwork(imageUrl: modele.imageUrl, estProgramme: false, taille: 76, rayon: AppRadius.radiusMd),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(modele.libelle, style: AppTextStyles.cardTitle),
                  if ((modele.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(modele.description!,
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xxs,
                    children: [
                      for (final (icone, texte) in caracteristiques)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(icone, size: 14, color: AppColors.primaryOcre),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(texte, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                        ]),
                    ],
                  ),
                  if (modele.terrainRequis != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      compatible ? modele.terrainRequis! : 'Non adapté à votre terrain · ${modele.terrainRequis}',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11, color: compatible ? AppColors.textMuted : AppColors.errorRed),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
