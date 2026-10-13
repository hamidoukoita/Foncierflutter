import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/geo_distance.dart';
import '../../domain/commodite_icone.dart';
import '../../domain/lieu_carte.dart';

/// Badge d'une commodité : pictogramme, nom et distance au bien.
class CommoditeChip extends StatelessWidget {
  final CommoditeProche item;
  final bool selectionne;
  final VoidCallback? onTap;

  const CommoditeChip({
    super.key,
    required this.item,
    this.selectionne = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distance = item.distanceMetres;
    final fond =
        selectionne ? AppColors.primaryBlueAnthracite : AppColors.white;
    final texte =
        selectionne ? AppColors.white : AppColors.primaryBlueAnthracite;

    return Material(
      color: fond,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: BorderSide(
          color: selectionne
              ? AppColors.primaryBlueAnthracite
              : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.radiusLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - AppSpacing.xs,
            vertical: AppSpacing.sm + AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selectionne
                      ? AppColors.primaryBlueSoft
                      : AppColors.warningAmberSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CommoditeIcone.de(item.commodite),
                  size: 16,
                  color: selectionne ? AppColors.white : AppColors.primaryOcre,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      item.commodite.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyles.h4.copyWith(fontSize: 13, color: texte),
                    ),
                  ),
                  Text(
                    distance == null
                        ? 'Distance non renseignée'
                        : 'à ${GeoDistance.format(distance)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selectionne
                          ? AppColors.onDarkMuted
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
