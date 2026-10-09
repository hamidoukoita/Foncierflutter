import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/reservation_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

class ProspectReservationsScreen extends ConsumerWidget {
  const ProspectReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mesReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOcre),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(mesReservationsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateView(
              icon: Icons.bookmark_outline,
              title: 'Mes réservations',
              message:
                  'Aucune réservation pour le moment.\nParcourez les programmes pour réserver un lot.',
            );
          }
          return RefreshIndicator(
            color: AppColors.primaryOcre,
            onRefresh: () async => ref.invalidate(mesReservationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: list.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${list.length} dossier${list.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReservationCard(reservation: list[i - 1]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
