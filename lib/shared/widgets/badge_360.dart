import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Pastille « 360° » posée sur une couverture : le bien propose une visite panoramique.
/// Invisible lorsqu'aucun panorama n'existe.
class Badge360 extends StatelessWidget {
  final int nombre;

  /// Version claire, pour un fond blanc (liste) plutôt qu'une photo.
  final bool surFondClair;

  const Badge360({super.key, required this.nombre, this.surFondClair = false});

  @override
  Widget build(BuildContext context) {
    if (nombre <= 0) return const SizedBox.shrink();
    final fond = surFondClair
        ? AppColors.primaryBlueAnthracite
        : AppColors.black.withValues(alpha: 0.55);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 1),
      decoration: BoxDecoration(color: fond, borderRadius: AppRadius.radiusRound),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.threesixty_rounded,
              size: 14, color: AppColors.primaryOcreLight),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            nombre > 1 ? '360° · $nombre vues' : 'Visite 360°',
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
