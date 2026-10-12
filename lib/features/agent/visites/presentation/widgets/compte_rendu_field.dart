import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Zone de saisie du compte-rendu de visite.
class CompteRenduField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const CompteRenduField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  static const OutlineInputBorder _bordure = OutlineInputBorder(
    borderRadius: AppRadius.radiusXl,
    borderSide: BorderSide(color: AppColors.borderLight, width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saisie du compte-rendu', style: AppTextStyles.h4),
        const SizedBox(height: 2),
        Text(
          'Observations sur place, demandes et retours du prospect',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller,
          enabled: enabled,
          minLines: 6,
          maxLines: 10,
          cursorColor: AppColors.primaryOcre,
          textCapitalization: TextCapitalization.sentences,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryBlueAnthracite,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Ex. : client satisfait du positionnement des bornes…',
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            border: _bordure,
            enabledBorder: _bordure,
            disabledBorder: _bordure,
            focusedBorder: _bordure.copyWith(
              borderSide:
                  const BorderSide(color: AppColors.primaryOcre, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
