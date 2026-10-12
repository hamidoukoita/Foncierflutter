import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'day_chip.dart';

/// Bandeau horizontal des jours de la semaine glissante.
class DaySelectorStrip extends StatelessWidget {
  final List<DateTime> jours;
  final DateTime jourSelectionne;
  final bool Function(DateTime jour) aDesVisites;
  final ValueChanged<DateTime> onSelect;

  const DaySelectorStrip({
    super.key,
    required this.jours,
    required this.jourSelectionne,
    required this.aDesVisites,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < jours.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs + 2),
          Expanded(
            child: DayChip(
              jour: jours[i],
              selected: DateFormatter.estMemeJour(jours[i], jourSelectionne),
              aDesVisites: aDesVisites(jours[i]),
              onTap: () => onSelect(jours[i]),
            ),
          ),
        ],
      ],
    );
  }
}
