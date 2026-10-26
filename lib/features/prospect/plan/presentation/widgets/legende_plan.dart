import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/presentation/widgets/plan_masse_view.dart';

/// Légende des couleurs du plan : une pastille par statut, avec le nombre de lots.
/// « Indisponible » n'apparaît que si des lots le sont.
class LegendePlan extends StatelessWidget {
  final List<PlanLotShape> lots;

  const LegendePlan({super.key, required this.lots});

  @override
  Widget build(BuildContext context) {
    int nombre(LotFamille f) => lots.where((l) => l.famille == f).length;
    final familles = [
      LotFamille.libre,
      LotFamille.reserve,
      LotFamille.vendu,
      if (nombre(LotFamille.indisponible) > 0) LotFamille.indisponible,
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final f in familles) _EntreeLegende(famille: f, nombre: nombre(f)),
      ],
    );
  }
}

class _EntreeLegende extends StatelessWidget {
  final LotFamille famille;
  final int nombre;

  const _EntreeLegende({required this.famille, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: couleurFamille(famille), borderRadius: AppRadius.radiusSm),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text('${libelleFamille(famille)} ($nombre)', style: AppTextStyles.bodySmall),
      ],
    );
  }
}
