import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/bien_foncier_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_booking_sheet.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Onglet « Parcelles » : parcelles individuelles, recherche et filtre par statut.
class ProspectParcellesScreen extends ConsumerStatefulWidget {
  const ProspectParcellesScreen({super.key});

  @override
  ConsumerState<ProspectParcellesScreen> createState() => _ProspectParcellesScreenState();
}

class _ProspectParcellesScreenState extends ConsumerState<ProspectParcellesScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// TOUTES | DISPONIBLES | RESERVEES
  String _filtre = 'TOUTES';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<BienFoncierModel> _filtrer(List<BienFoncierModel> source) {
    var list = source;
    if (_filtre == 'DISPONIBLES') {
      list = list.where((b) => b.isDisponible).toList();
    } else if (_filtre == 'RESERVEES') {
      list = list.where((b) => b.isReserve).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((b) =>
              b.reference.toLowerCase().contains(q) ||
              (b.numeroTitreFoncier ?? '').toLowerCase().contains(q) ||
              (b.societeNom ?? '').toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(parcellesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOcre),
        ),
        error: (e, _) => EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Parcelles indisponibles',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(parcellesProvider),
        ),
        data: (parcelles) {
          final list = _filtrer(parcelles);
          return RefreshIndicator(
            color: AppColors.primaryOcre,
            onRefresh: () async => ref.invalidate(parcellesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une parcelle, un titre foncier…',
                    prefixIcon: const Icon(Icons.search, color: AppColors.searchIcon),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip('Toutes (${parcelles.length})', 'TOUTES'),
                    _chip('Disponibles (${parcelles.where((b) => b.isDisponible).length})', 'DISPONIBLES'),
                    _chip('Réservées (${parcelles.where((b) => b.isReserve).length})', 'RESERVEES'),
                  ],
                ),
                const SizedBox(height: 14),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: EmptyStateView(
                      icon: Icons.grid_view_outlined,
                      title: 'Aucune parcelle trouvée',
                      message: 'Aucune parcelle ne correspond à votre recherche ou au filtre choisi.',
                    ),
                  )
                else
                  for (final b in list)
                    BienFoncierCard(
                      bien: b,
                      onTap: () => context.push('/prospect/parcelles/${b.id}'),
                      onReserver: () => reserverBienAvecConfirmation(
                        context,
                        ref,
                        bienId: b.id,
                        libelle: b.designation,
                      ),
                      onPrendreRdv: () => RdvBookingSheet.show(
                        context,
                        bienId: b.id,
                        societeId: b.societeId,
                        bienLabel: b.designation,
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filtre == value,
      selectedColor: AppColors.primaryOcre.withValues(alpha: 0.2),
      onSelected: (_) => setState(() => _filtre = value),
    );
  }
}
