import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../controllers/agent_planning_controller.dart';

/// Onglets « Ce jour / À venir / Effectuées » en pilules.
class VisiteFilterTabs extends StatelessWidget {
  final OngletVisites selection;
  final Map<OngletVisites, int?> compteurs;
  final ValueChanged<OngletVisites> onChanged;

  const VisiteFilterTabs({
    super.key,
    required this.selection,
    required this.compteurs,
    required this.onChanged,
  });

  static const Map<OngletVisites, String> _libelles = {
    OngletVisites.ceJour: 'Ce jour',
    OngletVisites.aVenir: 'À venir',
    OngletVisites.effectuees: 'Effectuées',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final onglet in OngletVisites.values) ...[
          if (onglet != OngletVisites.values.first)
            const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Pilule(
              label: _libelle(onglet),
              selected: onglet == selection,
              onTap: () => onChanged(onglet),
            ),
          ),
        ],
      ],
    );
  }

  String _libelle(OngletVisites onglet) {
    final compteur = compteurs[onglet];
    final base = _libelles[onglet]!;
    return compteur == null ? base : '$base ($compteur)';
  }
}

class _Pilule extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pilule({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryBlueAnthracite : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: BorderSide(
          color: selected
              ? AppColors.primaryBlueAnthracite
              : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: InkWell(
        customBorder:
            const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  selected ? AppColors.white : AppColors.primaryBlueAnthracite,
            ),
          ),
        ),
      ),
    );
  }
}
