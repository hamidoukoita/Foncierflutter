import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Section titrée qui fait défiler des cartes horizontalement (choix d'un modèle, d'une maison).
class CarrouselChoix extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final double hauteur;
  final int nombre;
  final IndexedWidgetBuilder itemBuilder;

  const CarrouselChoix({
    super.key,
    required this.titre,
    required this.nombre,
    required this.itemBuilder,
    this.sousTitre,
    this.hauteur = 252,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(titre, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700))),
            if (nombre > 1)
              Text('$nombre · faites défiler', style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
          ],
        ),
        if (sousTitre != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(sousTitre!, style: AppTextStyles.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: hauteur,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            itemCount: nombre,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md - AppSpacing.xs),
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}
