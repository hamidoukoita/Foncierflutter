import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BienFoncierCard extends StatelessWidget {
  final BienFoncierModel bien;
  final VoidCallback onReserver;
  final VoidCallback onPrendreRdv;

  const BienFoncierCard({
    super.key,
    required this.bien,
    required this.onReserver,
    required this.onPrendreRdv,
  });

  @override
  Widget build(BuildContext context) {
    // Statut : 🟢 DISPONIBLE, 🟡 RESERVER (Ambre), 🔴 VENDUE/EN_LITIGE
    Color badgeColor = AppColors.successGreen;
    String badgeText = bien.statut;
    if (bien.statut == 'RESERVER') {
      badgeColor = AppColors.ambreReservation24h;
    } else if (bien.statut == 'VENDUE' ||
        bien.statut == 'EN_LITIGE' ||
        bien.statut == 'INDISPONIBLE') {
      badgeColor = AppColors.errorRed;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImage(badgeColor, badgeText),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bien.typeBien == 'LOT_PROGRAMME'
                      ? 'Lot ${bien.numeroLot} - Ilot ${bien.numeroIlot}'
                      : 'Parcelle - TF: ${bien.numeroTitreFoncier ?? "N/A"}',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  bien.programmeNom ?? bien.societeNom ?? 'Bien Foncier+',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${bien.superficie} m²',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      '${bien.prix.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.price,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (bien.statut == 'DISPONIBLE')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onReserver,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOcre,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
                          ),
                          child: const Text('Réserver 24h'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onPrendreRdv,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlueAnthracite,
                            side: const BorderSide(
                                color: AppColors.primaryBlueAnthracite),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
                          ),
                          child: const Text('Prendre RDV'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Color badgeColor, String badgeText) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: CachedNetworkImage(
            imageUrl: 'https://via.placeholder.com/400x200.png?text=Foncier+',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Container(
              height: 160,
              color: AppColors.grey300,
              child: const Icon(Icons.image_not_supported,
                  color: AppColors.grey500),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
