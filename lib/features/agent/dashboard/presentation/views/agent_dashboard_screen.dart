import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_session.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/agent_async_view.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/reservation_suivi_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/section_header.dart';
import '../controllers/agent_dashboard_controller.dart';
import '../widgets/agent_profile_header.dart';
import '../widgets/kpi_metric_card.dart';
import '../widgets/prochaine_visite_card.dart';

/// Vue d'ensemble de l'agent collaborateur.
class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lecture nullable : l'écran reste stable pendant la déconnexion.
    final agent = ref.watch(authProvider).user;
    if (agent == null) return const SizedBox.shrink();
    final dashboard = ref.watch(agentDashboardProvider);

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primaryOcre,
        onRefresh: () => rafraichirDashboardAgent(ref),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
          children: [
            AgentProfileHeader(
              agent: agent,
              onDeconnexion: () => AgentSession.deconnecter(context, ref),
            ),
            const SizedBox(height: AppSpacing.lg),
            AgentAsyncView<AgentDashboardState>(
              value: dashboard,
              onRetry: () => rafraichirDashboardAgent(ref),
              builder: (state) => _DashboardContenu(state: state),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContenu extends StatelessWidget {
  final AgentDashboardState state;

  const _DashboardContenu({required this.state});

  @override
  Widget build(BuildContext context) {
    final prochaine = state.prochaineVisite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: KpiMetricCard(
                icon: Icons.calendar_today_outlined,
                iconBackground: AppColors.warningAmberSoft,
                iconColor: AppColors.primaryOcre,
                value: state.visitesDuJour,
                label: 'Visites ce jour',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: KpiMetricCard(
                icon: Icons.check_box_outlined,
                value: state.dossiersEnCours,
                valueColor: AppColors.primaryOcre,
                label: 'Dossiers 24h',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ProchaineVisiteCard(
          visite: prochaine,
          onTap: prochaine == null
              ? null
              : () => context.push(AgentRoutes.visiteDetail(prochaine.id)),
          onAppeler: () =>
              AgentActions.appeler(context, prochaine?.acquereurTelephone),
          onItineraire: () => AgentActions.itineraireIndisponible(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Réservations sous votre suivi',
          actionLabel: state.reservationsSuivies.isEmpty
              ? null
              : 'Voir tout (${state.reservationsSuivies.length})',
          onAction: () => context.push(AgentRoutes.reservations),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.apercuReservations.isEmpty)
          Text(
            'Aucune réservation ne vous est assignée.',
            style: AppTextStyles.bodyMedium,
          )
        else
          for (final reservation in state.apercuReservations)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ReservationSuiviCard(reservation: reservation),
            ),
      ],
    );
  }
}
