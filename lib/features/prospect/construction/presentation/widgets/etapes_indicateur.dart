import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../controllers/soumission_controller.dart';

/// Progression du formulaire : pastilles numérotées reliées par un trait.
class EtapesIndicateur extends StatelessWidget {
  final EtapeSoumission courante;
  const EtapesIndicateur({super.key, required this.courante});

  @override
  Widget build(BuildContext context) {
    final etapes = EtapeSoumission.values;
    return Row(
      children: [
        for (var i = 0; i < etapes.length; i++) ...[
          _Pastille(
            numero: i + 1,
            libelle: etapes[i].libelle,
            faite: i < courante.index,
            active: i == courante.index,
          ),
          if (i < etapes.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i < courante.index ? AppColors.primaryOcre : AppColors.borderLight,
              ),
            ),
        ],
      ],
    );
  }
}

class _Pastille extends StatelessWidget {
  final int numero;
  final String libelle;
  final bool faite;
  final bool active;
  const _Pastille({required this.numero, required this.libelle, required this.faite, required this.active});

  @override
  Widget build(BuildContext context) {
    final couleur = faite || active ? AppColors.primaryOcre : AppColors.grey400;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: faite ? AppColors.primaryOcre : (active ? AppColors.primaryOcreSoft : AppColors.white),
            border: Border.all(color: couleur, width: 2),
          ),
          child: faite
              ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
              : Text('$numero',
                  style: AppTextStyles.bodySmall.copyWith(color: couleur, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(libelle,
            style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: active ? AppColors.primaryBlueAnthracite : AppColors.textMuted,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
      ],
    );
  }
}
