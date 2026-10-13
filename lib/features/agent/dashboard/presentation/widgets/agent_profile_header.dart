import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import 'agent_avatar.dart';

/// En-tête : avatar, nom, société / fonction et bouton de déconnexion.
class AgentProfileHeader extends StatelessWidget {
  final AuthUser agent;
  final VoidCallback onDeconnexion;

  const AgentProfileHeader({
    super.key,
    required this.agent,
    required this.onDeconnexion,
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
        Tooltip(
          message: 'Se déconnecter',
          child: CircleIconButton(
            icon: Icons.logout_rounded,
            onPressed: onDeconnexion,
          ),
        ),
      ],
    );
  }
}
