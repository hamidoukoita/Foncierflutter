import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/badge_360.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/societe_logo.dart';
import '../../domain/annonce_accueil.dart';
import 'annonce_artwork.dart';

/// Carte d'annonce de l'accueil (cité ou parcelle individuelle).
class AnnonceCard extends StatelessWidget {
  final AnnonceAccueil annonce;
  final VoidCallback onTap;

  const AnnonceCard({super.key, required this.annonce, required this.onTap});

  String get _titre {
    final p = annonce.programme;
    if (p != null) return p.nom;
    return 'Parcelle ${annonce.bien!.superficie.toStringAsFixed(0)} m²';
  }

  String get _sousTitre {
    final valeurs = annonce.estProgramme
        ? [annonce.programme!.lieu, annonce.programme!.societeNom]
        : [
            annonce.bien!.localisation,
            annonce.bien!.societeNom,
            annonce.bien!.reference
          ];
    return valeurs.firstWhere((v) => v != null && v.trim().isNotEmpty,
            orElse: () => null) ??
        'Localisation non renseignée';
  }

  @override
  Widget build(BuildContext context) {
    final prix = annonce.prix;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
      child: Row(
        children: [
          Stack(
            children: [
              AnnonceArtwork(
                  imageUrl:
                      annonce.programme?.imageUrl ?? annonce.bien?.imageUrl,
                  estProgramme: annonce.estProgramme),
              Positioned(
                left: AppSpacing.xs,
                bottom: AppSpacing.xs,
                child: Badge360(
                    nombre: annonce.programme?.nombrePanoramas ??
                        annonce.bien?.nombrePanoramas ??
                        0),
              ),
              Positioned(
                left: AppSpacing.xs,
                top: AppSpacing.xs,
                child: SocieteLogo(
                  logoUrl: annonce.programme?.societeLogoUrl ?? annonce.bien?.societeLogoUrl,
                  nom: annonce.programme?.societeNom ?? annonce.bien?.societeNom,
                  taille: 24,
                  surPhoto: true,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftBadge(
                  label: annonce.estProgramme ? 'Cité' : 'Parcelle titrée',
                  background: annonce.estProgramme
                      ? AppColors.successGreenSoft
                      : AppColors.primaryOcreSoft,
                  foreground: annonce.estProgramme
                      ? AppColors.successGreen
                      : AppColors.primaryOcreDark,
                ),
                const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                Text(_titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: AppColors.primaryOcre),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(_sousTitre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (prix != null && prix > 0)
                  Text.rich(
                    TextSpan(
                      text: annonce.estProgramme ? 'À partir de ' : '',
                      style: AppTextStyles.bodySmall,
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.fcfaCompact(prix),
                          style: AppTextStyles.price
                              .copyWith(color: AppColors.primaryOcreDark),
                        ),
                      ],
                    ),
                  )
                else if (annonce.programme?.totalLots != null)
                  Text('${annonce.programme!.totalLots} lots',
                      style: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
        ],
      ),
    );
  }
}
