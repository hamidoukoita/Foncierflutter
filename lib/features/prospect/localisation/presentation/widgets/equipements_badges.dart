import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';

/// Viabilisation présente sur le site (VRD).
class EquipementsBadges extends StatelessWidget {
  final List<String> equipements;

  const EquipementsBadges({super.key, required this.equipements});

  static const List<(String, IconData)> _icones = [
    ('eau', Icons.water_drop_rounded),
    ('edm', Icons.bolt_rounded),
    ('voie', Icons.add_road_rounded),
  ];

  static IconData _icone(String equipement) {
    final texte = equipement.toLowerCase();
    for (final (cle, icone) in _icones) {
      if (texte.contains(cle)) return icone;
    }
    return Icons.fence_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final e in equipements)
          SoftBadge(
            label: e,
            icon: _icone(e),
            background: AppColors.successGreenSoft,
            foreground: AppColors.successGreen,
          ),
      ],
    );
  }
}
