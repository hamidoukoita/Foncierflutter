import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/bien_foncier_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/reservation_card.dart';

class ProspectDashboardScreen extends ConsumerWidget {
  const ProspectDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(prospectDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: RefreshIndicator(
        onRefresh: () => ref.read(prospectDashboardProvider.notifier).refresh(),
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
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(prospectDashboardProvider.notifier).refresh(),
                  child: const Text('Réessayer'),
                )
              ],
            ),
          ),
          data: (state) {
            return CustomScrollView(
              slivers: [
                _buildHeader(context, state, ref),
                if (state.mesReservations.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text('Mes Réservations (24h)',
                          style: AppTextStyles.h3),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: ReservationCard(
                              reservation: state.mesReservations[index]),
                        );
                      },
                      childCount: state.mesReservations.length,
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text('Catalogue des biens', style: AppTextStyles.h3),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final bien = state.catalogue[index];
                      if (state.filtreType != 'TOUT' &&
                          bien.typeBien != state.filtreType) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: BienFoncierCard(
                          bien: bien,
                          onReserver: () async {
                            final success = await ref
                                .read(prospectDashboardProvider.notifier)
                                .reserverBien(bien.id);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Réservation 24h effectuée avec succès !')),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Erreur lors de la réservation.')),
                              );
                            }
                          },
                          onPrendreRdv: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Fonction RDV à implémenter')),
                            );
                          },
                        ),
                      );
                    },
                    childCount: state.catalogue.length,
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

  Widget _buildHeader(
      BuildContext context, ProspectDashboardState state, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  isSelected: state.filtreType == 'TOUT',
                  onTap: () => ref
                      .read(prospectDashboardProvider.notifier)
                      .setFiltreType('TOUT'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Lots',
                  isSelected: state.filtreType == 'LOT_PROGRAMME',
                  onTap: () => ref
                      .read(prospectDashboardProvider.notifier)
                      .setFiltreType('LOT_PROGRAMME'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Parcelles',
                  isSelected: state.filtreType == 'PARCELLE_INDIVIDUELLE',
                  onTap: () => ref
                      .read(prospectDashboardProvider.notifier)
                      .setFiltreType('PARCELLE_INDIVIDUELLE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlueAnthracite
              : AppColors.backgroundOffWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlueAnthracite
                  : AppColors.borderLight),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
