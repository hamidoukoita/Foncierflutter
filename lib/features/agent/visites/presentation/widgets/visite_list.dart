import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_routes.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../controllers/agent_planning_controller.dart';
import 'visite_card.dart';

/// Liste des visites de l'onglet courant (ou état vide).
class VisiteList extends StatelessWidget {
  final List<RendezVousModel> visites;
  final OngletVisites onglet;
  final int? prochaineId;

  const VisiteList({
    super.key,
    required this.visites,
    required this.onglet,
    required this.prochaineId,
  });

  static const Map<OngletVisites, String> _messagesVides = {
    OngletVisites.ceJour: 'Aucune visite prévue ce jour.',
    OngletVisites.aVenir: 'Aucune visite à venir.',
    OngletVisites.effectuees: 'Aucune visite effectuée pour le moment.',
  };

  @override
  Widget build(BuildContext context) {
    if (visites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: EmptyStateView(
          icon: Icons.event_busy_outlined,
          title: 'Rien à afficher',
          message: _messagesVides[onglet]!,
        ),
      );
    }

    return Column(
      children: [
        for (final visite in visites)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: VisiteCard(
              visite: visite,
              estProchaine: visite.id == prochaineId,
              afficherJour: onglet != OngletVisites.ceJour,
              onAppeler: () =>
                  AgentActions.appeler(context, visite.acquereurTelephone),
              onItineraire: () => AgentActions.itineraireIndisponible(context),
              onDetails: () =>
                  context.push(AgentRoutes.visiteDetail(visite.id)),
            ),
          ),
      ],
    );
  }
}
