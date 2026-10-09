import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';

class LotCard extends StatelessWidget {
  final LotProgramme lot;
  final VoidCallback? onTap;

  const LotCard({super.key, required this.lot, this.onTap});

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'F', decimalDigits: 0);
    final statut = (lot.statut ?? '—').toUpperCase();
    final disponible = lot.isDisponible;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        leading: CircleAvatar(
          backgroundColor: disponible
              ? AppColors.successGreen.withOpacity(0.15)
              : AppColors.grey300,
          child: Icon(
            Icons.grid_view_rounded,
            color: disponible ? AppColors.successGreen : AppColors.grey500,
            size: 20,
          ),
        ),
        title: Text(
          lot.displayRef,
          style: AppTextStyles.h4,
        ),
        subtitle: Text(
          [
            if (lot.superficie != null) '${lot.superficie!.toStringAsFixed(0)} m²',
            if (lot.prix != null) priceFmt.format(lot.prix),
          ].join(' · '),
          style: AppTextStyles.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: disponible
                ? AppColors.successGreen.withOpacity(0.12)
                : AppColors.primaryOcre.withOpacity(0.12),
            borderRadius: AppRadius.radiusSm,
          ),
          child: Text(
            statut,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: disponible ? AppColors.successGreen : AppColors.primaryOcre,
            ),
          ),
        ),
      ),
    );
  }
}
