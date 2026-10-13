import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/zones_exploration.dart';

/// Bandeau « Explorer par zone » : chaque zone ouvre le catalogue filtré.
class ZonesStrip extends StatelessWidget {
  final List<ZoneExploration> zones;
  final ValueChanged<String> onZone;

  const ZonesStrip({super.key, required this.zones, required this.onZone});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        clipBehavior: Clip.none,
        itemCount: zones.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
        itemBuilder: (_, i) =>
            _ZoneChip(zone: zones[i], onTap: () => onZone(zones[i].nom)),
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final ZoneExploration zone;
  final VoidCallback onTap;

  const _ZoneChip({required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: AppRadius.radiusXl, boxShadow: AppShadows.card),
      child: Material(
        color: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXl,
          side: BorderSide(color: AppColors.borderLight),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm + AppSpacing.xxs,
                AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.primaryOcreSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.place_rounded,
                      size: 20, color: AppColors.primaryOcre),
                ),
                const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.nom,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
                    Text(
                      '${zone.nombreCites} cité${zone.nombreCites > 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
