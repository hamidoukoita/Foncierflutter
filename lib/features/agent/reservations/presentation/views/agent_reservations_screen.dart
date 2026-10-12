import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/reservation_suivi.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/agent_async_view.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/reservation_suivi_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/back_title_header.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Liste complète des réservations suivies par l'agent.
class AgentReservationsScreen extends ConsumerWidget {
  const AgentReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(agentReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BackTitleHeader(title: 'Réservations sous votre suivi'),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: AgentAsyncView<List<ReservationModel>>(
                  value: reservations,
                  onRetry: () => ref.invalidate(agentReservationsProvider),
                  builder: (liste) {
                    final suivies = ReservationsSuivi.trier(liste);
                    if (suivies.isEmpty) {
                      return const EmptyStateView(
                        icon: Icons.folder_open_outlined,
                        title: 'Aucune réservation',
                        message: 'Aucune réservation ne vous est assignée.',
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.primaryOcre,
                      onRefresh: () async {
                        ref.invalidate(agentReservationsProvider);
                        await ref.read(agentReservationsProvider.future);
                      },
                      child: ListView.separated(
                        itemCount: suivies.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (_, i) =>
                            ReservationSuiviCard(reservation: suivies[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
