import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Onglet « Mes visites » : demandes de visite de l'acquéreur, à venir puis passées / refusées.
class ProspectMesVisitesScreen extends ConsumerWidget {
  const ProspectMesVisitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mesVisitesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOcre),
        ),
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
            color: AppColors.primaryOcre,
            onRefresh: () async => ref.invalidate(mesVisitesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                if (aVenir.isNotEmpty) ..._section('À venir', aVenir),
                if (autres.isNotEmpty) ..._section('Passées ou refusées', autres),
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
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(
          '$titre (${items.length})',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textSecondary),
        ),
      ),
      for (final r in items) RdvCard(rdv: r),
    ];
  }
}
