import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/annonce_artwork.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/badge_360.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import '../../domain/maison_cle_en_main.dart';

/// Carte d'une maison clé en main : couverture, statut, 360°, pièces, surface, prix.
class MaisonCard extends StatelessWidget {
  final MaisonCleEnMain maison;
  final VoidCallback onTap;

  const MaisonCard({super.key, required this.maison, required this.onTap});

  static const double _hauteurCouverture = 170;

  @override
  Widget build(BuildContext context) {
    final famille = familleDeStatut(maison.statut);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: AppRadius.card, boxShadow: AppShadows.card),
      child: Material(
        color: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AnnonceArtwork(
                    imageUrl: maison.imageUrl,
                    estProgramme: false,
                    largeur: double.infinity,
                    hauteur: _hauteurCouverture,
                    rayon: BorderRadius.zero,
                  ),
                  Positioned(
                    left: AppSpacing.md - AppSpacing.xs,
                    top: AppSpacing.md - AppSpacing.xs,
                    child: SoftBadge(
                      label: libelleFamille(famille),
                      background: AppColors.white,
                      foreground: couleurFamille(famille),
                      icon: Icons.circle,
                    ),
                  ),
                  const Positioned(
                    right: AppSpacing.md - AppSpacing.xs,
                    top: AppSpacing.md - AppSpacing.xs,
                    child: SoftBadge(
                      label: 'Clé en main',
                      icon: Icons.key_rounded,
                      background: AppColors.white,
                      foreground: AppColors.primaryBlueAnthracite,
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md - AppSpacing.xs,
                    bottom: AppSpacing.md - AppSpacing.xs,
                    child: Badge360(nombre: maison.nombrePanoramas),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(maison.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 17)),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primaryOcre),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            [maison.adresse, maison.societeNom].whereType<String>().join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md - AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: AppSpacing.sm + AppSpacing.xxs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              if (maison.nombreChambres != null)
                                _Caracteristique(Icons.bed_outlined, '${maison.nombreChambres} ch.'),
                              if (maison.nombreSallesBain != null)
                                _Caracteristique(Icons.bathtub_outlined, '${maison.nombreSallesBain} sdb'),
                              if (maison.surfaceHabitable != null)
                                _Caracteristique(Icons.home_outlined,
                                    '${maison.surfaceHabitable!.toStringAsFixed(0)} m²'),
                            ],
                          ),
                        ),
                        Text(CurrencyFormatter.fcfaCompact(maison.prix),
                            style: AppTextStyles.price.copyWith(color: AppColors.primaryOcreDark, fontSize: 17)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Caracteristique extends StatelessWidget {
  final IconData icone;
  final String texte;
  const _Caracteristique(this.icone, this.texte);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 15, color: AppColors.primaryOcre),
        const SizedBox(width: AppSpacing.xxs),
        Text(texte, style: AppTextStyles.label),
      ],
    );
  }
}
