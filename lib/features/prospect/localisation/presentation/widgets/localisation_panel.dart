import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../../domain/lieu_carte.dart';
import 'commodites_carousel.dart';
import 'equipements_badges.dart';
import 'equipements_internes_badges.dart';
import 'precision_note.dart';

/// Panneau bas de la carte : précision, commodités à proximité, VRD.
class LocalisationPanel extends StatelessWidget {
  final LieuCarte lieu;
  final Object? selection;
  final ValueChanged<CommoditeProche>? onSelectCommodite;

  const LocalisationPanel({
    super.key,
    required this.lieu,
    this.selection,
    this.onSelectCommodite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        boxShadow: AppShadows.floating,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: AppRadius.radiusRound,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Commodités à proximité', style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            CommoditesCarousel(
              commodites: lieu.commodites,
              selection: selection,
              onSelect: onSelectCommodite,
            ),
            if (lieu.equipementsInternes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Dans la cité', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              EquipementsInternesBadges(equipements: lieu.equipementsInternes),
            ],
            if (lieu.equipementsSurSite.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Viabilisation sur site', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              EquipementsBadges(equipements: lieu.equipementsSurSite),
            ],
            const SizedBox(height: AppSpacing.md),
            PrecisionNote(precision: lieu.precision),
          ],
        ),
      ),
    );
  }
}
