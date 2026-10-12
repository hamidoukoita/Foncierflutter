import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';

class PlanningHeader extends StatelessWidget {
  final String? societeNom;
  final VoidCallback onCalendrier;

  const PlanningHeader({
    super.key,
    required this.societeNom,
    required this.onCalendrier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Planning des Visites', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                societeNom == null
                    ? 'Visites de parcelles qui vous sont assignées'
                    : 'Visites de parcelles assignées par $societeNom',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        CircleIconButton(
          icon: Icons.calendar_today_outlined,
          onPressed: onCalendrier,
        ),
      ],
    );
  }
}
