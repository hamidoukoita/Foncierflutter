import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../../domain/lieu_carte.dart';
import 'commodite_chip.dart';

/// Carrousel horizontal des commodités, de la plus proche à la plus lointaine.
class CommoditesCarousel extends StatelessWidget {
  final List<CommoditeProche> commodites;
  final Object? selection;
  final ValueChanged<CommoditeProche>? onSelect;

  const CommoditesCarousel({
    super.key,
    required this.commodites,
    this.selection,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (commodites.isEmpty) {
      return Text(
        'Aucune commodité renseignée pour ce bien.',
        style: AppTextStyles.bodyMedium,
      );
    }
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: commodites.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final item = commodites[i];
          return CommoditeChip(
            item: item,
            selectionne: item.commodite.id == selection,
            onTap: onSelect == null ? null : () => onSelect!(item),
          );
        },
      ),
    );
  }
}
