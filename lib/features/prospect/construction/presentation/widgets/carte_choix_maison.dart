import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/annonce_artwork.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/badge_360.dart';

/// Carte d'un carrousel de choix de maison (modèle du catalogue ou maison clé en main) :
/// photo, pastille 360° qui lance la visite, caractéristiques et note éventuelle.
class CarteChoixMaison extends StatelessWidget {
  static const double largeur = 232;
  static const double hauteurPhoto = 132;

  final String titre;
  final String? imageUrl;
  final List<(IconData, String)> caracteristiques;
  final String? note;
  final bool noteEnAlerte;
  final int nombrePanoramas;
  final VoidCallback? onVoir360;
  final bool selectionnee;
  final bool active;
  final VoidCallback onTap;

  const CarteChoixMaison({
    super.key,
    required this.titre,
    required this.imageUrl,
    required this.caracteristiques,
    required this.selectionnee,
    required this.onTap,
    this.note,
    this.noteEnAlerte = false,
    this.nombrePanoramas = 0,
    this.onVoir360,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: largeur,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: selectionnee ? AppColors.primaryOcre : AppColors.borderLight,
            width: selectionnee ? 2 : 1,
          ),
          boxShadow: selectionnee ? AppShadows.card : AppShadows.soft,
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: AppRadius.radiusLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: active ? onTap : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AnnonceArtwork(
                      imageUrl: imageUrl,
                      estProgramme: false,
                      largeur: largeur,
                      hauteur: hauteurPhoto,
                      rayon: BorderRadius.zero,
                    ),
                    if (nombrePanoramas > 0)
                      Positioned(
                        left: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: Semantics(
                          button: true,
                          label: 'Visiter en 360°',
                          child: GestureDetector(
                            onTap: onVoir360,
                            child: Badge360(nombre: nombrePanoramas),
                          ),
                        ),
                      ),
                    if (selectionnee)
                      const Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                          child: Icon(Icons.check_circle_rounded, color: AppColors.primaryOcre, size: 24),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle),
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
                      if (note != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: noteEnAlerte ? AppColors.errorRed : AppColors.textMuted,
                            fontWeight: noteEnAlerte ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
