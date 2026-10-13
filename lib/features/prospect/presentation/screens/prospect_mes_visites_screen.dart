import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/section_header.dart';

/// Onglet « Mes visites » : demandes de visite de l'acquéreur, à venir puis passées / refusées.
class ProspectMesVisitesScreen extends ConsumerStatefulWidget {
  const ProspectMesVisitesScreen({super.key});

  @override
  ConsumerState<ProspectMesVisitesScreen> createState() =>
      _ProspectMesVisitesScreenState();
}

class _ProspectMesVisitesScreenState
    extends ConsumerState<ProspectMesVisitesScreen> {
  /// TOUTES | A_VENIR | PASSEES
  String _filtre = 'TOUTES';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(mesVisitesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Visites indisponibles',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(mesVisitesProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateView(
              icon: Icons.location_on_outlined,
              title: 'Mes visites',
              message:
                  'Aucune visite programmée.\nOuvrez un lot ou une parcelle et touchez « Prendre rendez-vous ».',
            );
          }

          final aVenir = list.where((r) => r.isAVenir).toList()
            ..sort((a, b) => a.dateRendezVous.compareTo(b.dateRendezVous));
          final autres = list.where((r) => !r.isAVenir).toList()
            ..sort((a, b) => b.dateRendezVous.compareTo(a.dateRendezVous));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mesVisitesProvider),
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
                    AppFilterOption('TOUTES', 'Toutes (${list.length})'),
                    AppFilterOption('A_VENIR', 'À venir (${aVenir.length})',
                        color: AppColors.lotDisponible),
                    AppFilterOption(
                        'PASSEES', 'Passées / annulées (${autres.length})',
                        color: AppColors.primaryBlueAnthracite),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (_filtre != 'PASSEES' && aVenir.isNotEmpty)
                  ..._section('À venir', aVenir),
                if (_filtre != 'A_VENIR' && autres.isNotEmpty)
                  ..._section('Passées ou annulées', autres),
                if ((_filtre == 'A_VENIR' && aVenir.isEmpty) ||
                    (_filtre == 'PASSEES' && autres.isEmpty))
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xxl),
                    child: EmptyStateView(
                      icon: Icons.event_busy_outlined,
                      title: 'Aucune visite',
                      message: 'Aucune visite ne correspond à ce filtre.',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _section(String titre, List<RendezVousModel> items) {
    return [
      Padding(
        padding: const EdgeInsets.only(
            bottom: AppSpacing.md - AppSpacing.xs, top: AppSpacing.xs),
        child: SectionHeader(
            title: titre,
            subtitle: '${items.length} visite${items.length > 1 ? 's' : ''}'),
      ),
      for (final r in items) ...[
        RdvCard(rdv: r),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }
}
