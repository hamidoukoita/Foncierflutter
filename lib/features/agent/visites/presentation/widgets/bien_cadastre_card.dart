import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/bien_libelle.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_placeholder.dart';

/// Résumé cadastral du bien : viabilisation (VRD) et prix officiel.
class BienCadastreCard extends StatelessWidget {
  final BienFoncierModel bien;

  const BienCadastreCard({super.key, required this.bien});

  String get _viabilisation {
    final equipements = BienLibelle.joindre([
      if (bien.murCloture == true) 'Clôture',
      if (bien.eauSomapep == true) 'Eau SOMAPEP',
      if (bien.electriciteEdm == true) 'EDM',
      if (bien.voieBitumee == true) 'Voie bitumée',
    ]);
    return equipements.isEmpty ? 'Viabilisation non renseignée' : equipements;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const ImagePlaceholder(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan cadastral & Bornage',
                  style: AppTextStyles.h4.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  _viabilisation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Prix net : ${CurrencyFormatter.fcfa(bien.prix)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryOcre,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
