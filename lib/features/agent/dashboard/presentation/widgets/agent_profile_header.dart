import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_sizes.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import 'agent_avatar.dart';

/// En-tête : avatar, nom, société / fonction et menu du compte (mot de passe, déconnexion).
class AgentProfileHeader extends StatelessWidget {
  final AuthUser agent;
  final VoidCallback onDeconnexion;
  final VoidCallback onChangerMotDePasse;

  const AgentProfileHeader({
    super.key,
    required this.agent,
    required this.onDeconnexion,
    required this.onChangerMotDePasse,
  });

  @override
  Widget build(BuildContext context) {
    final rattachement = [
      agent.societeNom,
      agent.fonctionLibelle ?? 'Agent Agréé',
    ].whereType<String>().join(' • ');

    return Row(
      children: [
        AgentAvatar(prenom: agent.prenom, nom: agent.nom),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormatter.dateLongue(DateTime.now()).toUpperCase(),
                style: AppTextStyles.overline,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                agent.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppSpacing.xs),
              SoftBadge(
                label: rattachement,
                background: AppColors.successGreenSoft,
                foreground: AppColors.successGreen,
              ),
            ],
          ),
        ),
        _MenuCompte(onChangerMotDePasse: onChangerMotDePasse, onDeconnexion: onDeconnexion),
      ],
    );
  }
}

enum _ActionCompte { motDePasse, deconnexion }

/// Menu du compte de l'agent.
class _MenuCompte extends StatelessWidget {
  final VoidCallback onChangerMotDePasse;
  final VoidCallback onDeconnexion;

  const _MenuCompte({required this.onChangerMotDePasse, required this.onDeconnexion});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ActionCompte>(
      tooltip: 'Mon compte',
      position: PopupMenuPosition.under,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      onSelected: (action) => switch (action) {
        _ActionCompte.motDePasse => onChangerMotDePasse(),
        _ActionCompte.deconnexion => onDeconnexion(),
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _ActionCompte.motDePasse,
          child: _LigneMenu(icone: Icons.key_rounded, libelle: 'Changer mon mot de passe', couleur: AppColors.primaryBlueAnthracite),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _ActionCompte.deconnexion,
          child: _LigneMenu(icone: Icons.logout_rounded, libelle: 'Se déconnecter', couleur: AppColors.errorRed),
        ),
      ],
      child: Container(
        width: AppSizes.iconButton,
        height: AppSizes.iconButton,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppShadows.soft,
        ),
        child: const Icon(Icons.manage_accounts_rounded, color: AppColors.primaryBlueAnthracite, size: 22),
      ),
    );
  }
}

class _LigneMenu extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final Color couleur;
  const _LigneMenu({required this.icone, required this.libelle, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 20, color: couleur),
        const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
        Text(libelle, style: AppTextStyles.bodyMedium.copyWith(color: couleur, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
