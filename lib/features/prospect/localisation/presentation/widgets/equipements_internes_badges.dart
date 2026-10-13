import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import '../../domain/commodite_icone.dart';

/// Équipements situés à l'intérieur de la cité (issus du plan de masse).
class EquipementsInternesBadges extends StatelessWidget {
  final List<String> equipements;

  const EquipementsInternesBadges({super.key, required this.equipements});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final e in equipements)
          SoftBadge(
            label: e,
            icon: CommoditeIcone.depuisTexte(e),
            background: AppColors.warningAmberSoft,
            foreground: AppColors.primaryBlueAnthracite,
          ),
      ],
    );
  }
}
