import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';

/// Informations du compte : modification du nom, du numéro de connexion et du mot de passe.
class ProfilInfos extends StatelessWidget {
  final AuthUser? user;
  final VoidCallback onModifierNom;
  final VoidCallback onModifierTelephone;
  final VoidCallback onChangerMotDePasse;

  const ProfilInfos({
    super.key,
    required this.user,
    required this.onModifierNom,
    required this.onModifierTelephone,
    required this.onChangerMotDePasse,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('INFORMATIONS DU COMPTE', style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          _Ligne(
              icone: Icons.badge_outlined,
              libelle: 'Prénom',
              valeur: user?.prenom ?? '—'),
          const Divider(),
          _Ligne(
              icone: Icons.person_outline_rounded,
              libelle: 'Nom',
              valeur: user?.nom ?? '—'),
          const Divider(),
          _Ligne(
            icone: Icons.phone_outlined,
            libelle: 'Téléphone',
            valeur: user?.telephone.isNotEmpty == true
                ? Telephone.afficher(user!.telephone, avecIndicatif: true)
                : '—',
          ),
          const SizedBox(height: AppSpacing.md),
          AppActionButton(
            label: 'Modifier mon nom',
            icon: Icons.edit_rounded,
            variant: AppActionVariant.soft,
            height: 44,
            onPressed: onModifierNom,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppActionButton(
            label: 'Changer de numéro',
            icon: Icons.phone_iphone_rounded,
            variant: AppActionVariant.soft,
            height: 44,
            onPressed: onModifierTelephone,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppActionButton(
            label: 'Changer mon mot de passe',
            icon: Icons.key_rounded,
            variant: AppActionVariant.soft,
            height: 44,
            onPressed: onChangerMotDePasse,
          ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final String valeur;
  const _Ligne(
      {required this.icone, required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: AppSpacing.sm + AppSpacing.xxs),
      child: Row(
        children: [
          Icon(icone, size: 19, color: AppColors.primaryOcre),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Text(libelle, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Flexible(
            child: Text(
              valeur,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
