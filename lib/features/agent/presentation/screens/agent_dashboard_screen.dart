import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/providers/agent_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/presentation/widgets/agent_kpi_grid.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/presentation/widgets/agent_reservation_card.dart';

class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(agentDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: RefreshIndicator(
        onRefresh: () => ref.read(agentDashboardProvider.notifier).refresh(),
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.errorRed, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text('Erreur: $err',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(agentDashboardProvider.notifier).refresh(),
                  child: const Text('Réessayer'),
                )
              ],
            ),
          ),
          data: (state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AgentKpiGrid(kpis: state.kpis),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pipeline des Réservations',
                            style: AppTextStyles.h3),
                        DropdownButton<String>(
                          value: state.filtreStatut,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                                value: 'TOUT', child: Text('Toutes')),
                            DropdownMenuItem(
                                value: 'EN_ATTENTE',
                                child: Text('En attente (24h)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(agentDashboardProvider.notifier)
                                  .setFiltreStatut(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reservation = state.reservationsDuJour[index];
                      if (state.filtreStatut != 'TOUT' &&
                          reservation.statut != state.filtreStatut) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: AgentReservationCard(
                          reservation: reservation,
                          onConfirmer: () {
                            // Appel backend pour confirmer
                          },
                          onAnnuler: () {
                            // Appel backend pour annuler / libérer
                          },
                        ),
                      );
                    },
                    childCount: state.reservationsDuJour.length,
                  ),
                ),
                const SliverPadding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xl * 2)),
              ],
            );
          },
        ),
      ),
    );
  }
}
