import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Carte blanche qui regroupe les champs d'un formulaire d'authentification.
class AuthCarte extends StatelessWidget {
  final List<Widget> children;

  const AuthCarte({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusXxl,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

/// Intitulé d'un groupe de champs dans une [AuthCarte] (Identité, Contact…).
class AuthSectionTitre extends StatelessWidget {
  final IconData icone;
  final String titre;

  const AuthSectionTitre({super.key, required this.icone, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md - AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
            decoration: const BoxDecoration(
                color: AppColors.primaryOcreSoft,
                borderRadius: AppRadius.radiusSm),
            child: Icon(icone, size: 16, color: AppColors.primaryOcre),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(titre.toUpperCase(), style: AppTextStyles.overline),
        ],
      ),
    );
  }
}
