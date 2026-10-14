import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/url_media.dart';
import '../../domain/societe_promotrice.dart';
import 'carte_selectionnable.dart';

/// Société agréée proposée comme constructeur.
class SocieteTile extends StatelessWidget {
  final SocietePromotrice societe;
  final bool selectionnee;
  final VoidCallback onTap;

  const SocieteTile({super.key, required this.societe, required this.selectionnee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final logo = UrlMedia.absolue(societe.logoUrl);
    final initiales = Container(
      color: AppColors.primaryBlueAnthracite,
      alignment: Alignment.center,
      child: Text(societe.initiales,
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.white, fontSize: 15)),
    );
    return CarteSelectionnable(
      selectionnee: selectionnee,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.radiusMd,
            child: SizedBox(
              width: 48,
              height: 48,
              child: logo == null
                  ? initiales
                  : CachedNetworkImage(imageUrl: logo, fit: BoxFit.cover, errorWidget: (_, __, ___) => initiales),
            ),
          ),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(societe.nom, style: AppTextStyles.cardTitle),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 13, color: AppColors.successGreen),
                      const SizedBox(width: AppSpacing.xxs),
                      Text('Promoteur agréé',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.successGreen, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  if ((societe.adresse ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(societe.adresse!,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall),
                  ],
                  if ((societe.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(societe.description!,
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall),
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
