import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/map_constants.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/map/foncier_osm_viewer.dart';
import '../../domain/lieu_carte.dart';

/// Aperçu cartographique dans une fiche (bien ou cité) avec accès à la carte.
class LocalisationPreviewCard extends StatelessWidget {
  static const double _hauteurCarte = 150;

  final LieuCarte lieu;
  final VoidCallback onOuvrir;

  const LocalisationPreviewCard({
    super.key,
    required this.lieu,
    required this.onOuvrir,
  });

  @override
  Widget build(BuildContext context) {
    final position = lieu.position;
    return Material(
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOuvrir,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _hauteurCarte,
              child: position == null
                  ? const ColoredBox(
                      color: AppColors.placeholderSurface,
                      child: Icon(Icons.location_off_outlined,
                          color: AppColors.grey500, size: 32),
                    )
                  // Aperçu statique : le geste est capté par la carte entière.
                  : IgnorePointer(
                      child: FoncierOsmViewer(
                        centre: position,
                        zoom: lieu.precision == PrecisionPosition.commune
                            ? MapConstants.zoomApproximatif
                            : MapConstants.zoomCite,
                        interactive: false,
                        afficherAttribution: false,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.warningAmberSoft,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.soft,
                    ),
                    child: const Icon(Icons.place_rounded,
                        size: 18, color: AppColors.primaryOcre),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voir la localisation', style: AppTextStyles.h4),
                        Text(
                          _resume,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primaryOcre),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _resume {
    if (lieu.position == null) return 'Coordonnées non renseignées';
    final n = lieu.commodites.length;
    if (n == 0) return 'Carte interactive OpenStreetMap';
    return '$n commodité${n > 1 ? 's' : ''} à proximité';
  }
}
