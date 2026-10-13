import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../../domain/lieu_carte.dart';

/// Avertit l'acquéreur quand la position n'est pas celle exacte du bien.
class PrecisionNote extends StatelessWidget {
  final PrecisionPosition? precision;

  const PrecisionNote({super.key, required this.precision});

  String? get _message => switch (precision) {
        PrecisionPosition.centreDesLots =>
          'Position du centre de la cité (coordonnées du bien non renseignées).',
        PrecisionPosition.commune =>
          'Position approximative : centre de la localité.',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final message = _message;
    if (message == null) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 14, color: AppColors.warningAmber),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
