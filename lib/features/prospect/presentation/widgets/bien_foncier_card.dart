import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/annonce_artwork.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/badge_360.dart';

/// Carte d'une parcelle (ou d'un lot) : couverture, statut, TF, surface, prix, actions.
class BienFoncierCard extends StatelessWidget {
  final BienFoncierModel bien;
  final VoidCallback onReserver;
  final VoidCallback onPrendreRdv;

  /// Ouvre la fiche détaillée du bien.
  final VoidCallback? onTap;

  const BienFoncierCard({
    super.key,
    required this.bien,
    required this.onReserver,
    required this.onPrendreRdv,
    this.onTap,
  });

  static const double _hauteurCouverture = 140;

  @override
  Widget build(BuildContext context) {
    final famille = familleDeStatut(bien.statut);
    final couleur = couleurFamille(famille);

    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: AppRadius.card, boxShadow: AppShadows.card),
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
                    imageUrl: bien.imageUrl,
                    estProgramme: bien.isLot,
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
                      foreground: couleur,
                      icon: Icons.circle,
                    ),
                  ),
                  if ((bien.numeroTitreFoncier ?? '').isNotEmpty)
                    const Positioned(
                      right: AppSpacing.md - AppSpacing.xs,
                      top: AppSpacing.md - AppSpacing.xs,
                      child: SoftBadge(
                        label: 'TF vérifié',
                        icon: Icons.verified_rounded,
                        background: AppColors.white,
                        foreground: AppColors.successGreen,
                      ),
                    ),
                  Positioned(
                    left: AppSpacing.md - AppSpacing.xs,
                    bottom: AppSpacing.md - AppSpacing.xs,
                    child: Badge360(nombre: bien.nombrePanoramas),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bien.designation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTextStyles.cardTitle.copyWith(fontSize: 17),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.fcfaCompact(bien.prix),
                          style: AppTextStyles.price.copyWith(
                              color: AppColors.primaryOcreDark, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _Infos(bien: bien),
                    if (bien.peutEtreReserve) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: DetailButton(
                              label: 'Réserver',
                              icon: Icons.bookmark_add_outlined,
                              compact: true,
                              onPressed: onReserver,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: DetailButton(
                              label: 'Prendre RDV',
                              icon: Icons.event_available_outlined,
                              compact: true,
                              outline: true,
                              onPressed: onPrendreRdv,
                            ),
                          ),
                        ],
                      ),
                    ],
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

/// Localisation, surface et viabilisation sur une ligne.
class _Infos extends StatelessWidget {
  final BienFoncierModel bien;
  const _Infos({required this.bien});

  @override
  Widget build(BuildContext context) {
    final lieu = [
      bien.programmeNom,
      bien.localisation,
      bien.societeNom
    ].firstWhere((v) => v != null && v.trim().isNotEmpty, orElse: () => null);
    return Row(
      children: [
        const Icon(Icons.square_foot_rounded,
            size: 15, color: AppColors.primaryOcre),
        const SizedBox(width: AppSpacing.xxs),
        Text('${bien.superficie.toStringAsFixed(0)} m²',
            style: AppTextStyles.label),
        if (lieu != null) ...[
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.location_on_rounded,
              size: 15, color: AppColors.primaryOcre),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Text(lieu,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium),
          ),
        ] else
          const Spacer(),
        if (bien.eauSomapep == true) const _Vrd(Icons.water_drop_rounded),
        if (bien.electriciteEdm == true) const _Vrd(Icons.bolt_rounded),
        if (bien.voieBitumee == true) const _Vrd(Icons.add_road_rounded),
      ],
    );
  }
}

class _Vrd extends StatelessWidget {
  final IconData icone;
  const _Vrd(this.icone);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.xs),
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
          color: AppColors.successGreenSoft, shape: BoxShape.circle),
      child: Icon(icone, size: 13, color: AppColors.successGreen),
    );
  }
}
