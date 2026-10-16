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

/// Regroupement des réservations par étape, pour les filtres.
enum _FiltreReservation {
  toutes,
  enCours,
  vendues,
  terminees;

  bool accepte(ReservationModel r) => switch (this) {
        _FiltreReservation.toutes => true,
        _FiltreReservation.enCours => r.estActive,
        _FiltreReservation.vendues => r.isVendue,
        _FiltreReservation.terminees => r.isExpiree || r.isAnnulee,
      };
}

class ProspectReservationsScreen extends ConsumerStatefulWidget {
  const ProspectReservationsScreen({super.key});

  @override
  ConsumerState<ProspectReservationsScreen> createState() =>
      _ProspectReservationsScreenState();
}

class _ProspectReservationsScreenState
    extends ConsumerState<ProspectReservationsScreen> {
  _FiltreReservation _filtre = _FiltreReservation.toutes;

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
          final list = sorted.where(_filtre.accepte).toList();
          int count(_FiltreReservation f) => all.where(f.accepte).length;

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
                AppFilterBar<_FiltreReservation>(
                  padding: EdgeInsets.zero,
                  selected: _filtre,
                  onChanged: (v) => setState(() => _filtre = v),
                  options: [
                    AppFilterOption(_FiltreReservation.toutes, 'Toutes (${all.length})'),
                    AppFilterOption(_FiltreReservation.enCours,
                        'En cours (${count(_FiltreReservation.enCours)})',
                        color: AppColors.ambreReservation24h),
                    AppFilterOption(_FiltreReservation.vendues,
                        'Vendues (${count(_FiltreReservation.vendues)})',
                        color: AppColors.successGreen),
                    AppFilterOption(_FiltreReservation.terminees,
                        'Expirées / annulées (${count(_FiltreReservation.terminees)})',
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
