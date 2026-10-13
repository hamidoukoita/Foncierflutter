import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/reservation_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

class ProspectReservationsScreen extends ConsumerStatefulWidget {
  const ProspectReservationsScreen({super.key});

  @override
  ConsumerState<ProspectReservationsScreen> createState() =>
      _ProspectReservationsScreenState();
}

class _ProspectReservationsScreenState
    extends ConsumerState<ProspectReservationsScreen> {
  /// TOUTES | EN_ATTENTE | CONFIRMER | REFUSER
  String _filtre = 'TOUTES';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(mesReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Réservations indisponibles',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(mesReservationsProvider),
        ),
        data: (all) {
          if (all.isEmpty) {
            return const EmptyStateView(
              icon: Icons.bookmark_outline,
              title: 'Mes réservations',
              message:
                  'Aucune réservation pour le moment.\nParcourez les programmes pour réserver un lot.',
            );
          }

          final sorted = [...all]
            ..sort((a, b) => b.dateReservation.compareTo(a.dateReservation));
          final list = _filtre == 'TOUTES'
              ? sorted
              : sorted.where((r) => r.statut == _filtre).toList();
          int count(String s) => all.where((r) => r.statut == s).length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mesReservationsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.xs,
                AppSpacing.pageHorizontal,
                AppSpacing.lg,
              ),
              children: [
                AppFilterBar<String>(
                  padding: EdgeInsets.zero,
                  selected: _filtre,
                  onChanged: (v) => setState(() => _filtre = v),
                  options: [
                    AppFilterOption('TOUTES', 'Toutes (${all.length})'),
                    AppFilterOption(
                        'EN_ATTENTE', 'En attente (${count('EN_ATTENTE')})',
                        color: AppColors.ambreReservation24h),
                    AppFilterOption(
                        'CONFIRMER', 'Confirmées (${count('CONFIRMER')})',
                        color: AppColors.successGreen),
                    AppFilterOption(
                        'REFUSER', 'Refusées / annulées (${count('REFUSER')})',
                        color: AppColors.errorRed),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xxl),
                    child: EmptyStateView(
                      icon: Icons.bookmark_outline,
                      title: 'Aucun dossier',
                      message: 'Aucune réservation ne correspond à ce filtre.',
                    ),
                  )
                else
                  for (final ReservationModel r in list) ...[
                    ReservationCard(reservation: r),
                    const SizedBox(height: AppSpacing.md),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}
