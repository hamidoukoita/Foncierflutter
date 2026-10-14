import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/shell/widgets/prospect_account_menu.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/foncier_logo.dart';

/// En-tête de l'accueil : logo Foncier+, salutation et accès au profil.
class AccueilHeader extends StatelessWidget {
  final AuthUser? user;

  const AccueilHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final prenom = user?.prenom.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const FoncierLogo.horizontal(hauteur: 34),
            const Spacer(),
            const ProspectAccountMenu(),
          ],
        ),
        const SizedBox(height: AppSpacing.md + AppSpacing.xs),
        Text(prenom.isEmpty ? 'Bonjour' : 'Bonjour, $prenom',
            style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Terrains titrés et viabilisés, sans litige.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
