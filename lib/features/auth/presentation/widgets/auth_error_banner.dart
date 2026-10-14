import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Message d'erreur des formulaires d'authentification.
class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: const BoxDecoration(
          color: AppColors.errorRedSoft, borderRadius: AppRadius.radiusMd),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 20, color: AppColors.errorRed),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: AppTextStyles.label.copyWith(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
