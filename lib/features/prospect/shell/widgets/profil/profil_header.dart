import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import 'profil_avatar.dart';

/// Identité de l'acquéreur : avatar, nom, téléphone, statut.
class ProfilHeader extends StatelessWidget {
  final AuthUser? user;
  final VoidCallback onFermer;

  const ProfilHeader({super.key, required this.user, required this.onFermer});

  @override
  Widget build(BuildContext context) {
    final actif = (user?.statut ?? 'ACTIF').toUpperCase() == 'ACTIF';
    return Column(
      children: [
        Row(
          children: [
            Text('MON PROFIL',
                style: AppTextStyles.overline
                    .copyWith(color: AppColors.primaryOcre)),
            const Spacer(),
            IconButton(
              tooltip: 'Fermer',
              onPressed: onFermer,
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.primaryBlueAnthracite),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfilAvatar(user: user, taille: 84),
        const SizedBox(height: AppSpacing.md - AppSpacing.xs),
        Text(
          user?.fullName.isNotEmpty == true ? user!.fullName : 'Mon compte',
          textAlign: TextAlign.center,
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (user?.telephone.isNotEmpty == true)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_rounded,
                  size: 15, color: AppColors.primaryOcre),
              const SizedBox(width: AppSpacing.xs),
              Text(Telephone.afficher(user!.telephone, avecIndicatif: true), style: AppTextStyles.bodyMedium),
            ],
          ),
        const SizedBox(height: AppSpacing.md - AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            const SoftBadge(
              label: 'Acquéreur',
              icon: Icons.person_rounded,
              background: AppColors.primaryOcreSoft,
              foreground: AppColors.primaryOcreDark,
            ),
            SoftBadge(
              label: actif
                  ? 'Compte actif'
                  : 'Compte ${user!.statut!.toLowerCase()}',
              icon: actif ? Icons.verified_rounded : Icons.info_outline_rounded,
              background: actif
                  ? AppColors.successGreenSoft
                  : AppColors.warningAmberSoft,
              foreground:
                  actif ? AppColors.successGreen : AppColors.primaryOcreDark,
            ),
          ],
        ),
      ],
    );
  }
}
