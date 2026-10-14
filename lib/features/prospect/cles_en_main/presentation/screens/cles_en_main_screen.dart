import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../cles_en_main_routes.dart';
import '../../domain/maison_cle_en_main.dart';
import '../../providers/maisons_providers.dart';
import '../widgets/maison_card.dart';

/// Onglet « Clés en main » : maisons prêtes à habiter, recherche et filtre de disponibilité.
class ClesEnMainScreen extends ConsumerStatefulWidget {
  const ClesEnMainScreen({super.key});

  @override
  ConsumerState<ClesEnMainScreen> createState() => _ClesEnMainScreenState();
}

class _ClesEnMainScreenState extends ConsumerState<ClesEnMainScreen> {
  final _recherche = TextEditingController();
  String _terme = '';

  /// TOUTES | DISPONIBLES | RESERVEES
  String _filtre = 'TOUTES';

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  List<MaisonCleEnMain> _filtrer(List<MaisonCleEnMain> source) {
    var liste = switch (_filtre) {
      'DISPONIBLES' => source.where((m) => m.isDisponible).toList(),
      'RESERVEES' => source.where((m) => m.isReserve).toList(),
      _ => source,
    };
    final q = _terme.trim().toLowerCase();
    if (q.isNotEmpty) {
      liste = liste
          .where((m) => [m.titre, m.adresse, m.societeNom, m.reference]
              .any((v) => (v ?? '').toLowerCase().contains(q)))
          .toList();
    }
    return liste;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(catalogueMaisonsProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
        error: (e, _) => EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Maisons indisponibles',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(catalogueMaisonsProvider),
        ),
        data: (maisons) {
          final liste = _filtrer(maisons);
          return RefreshIndicator(
            color: AppColors.primaryOcre,
            onRefresh: () async => ref.invalidate(catalogueMaisonsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.xs, AppSpacing.pageHorizontal, AppSpacing.lg),
              children: [
                AppSearchField(
                  controller: _recherche,
                  hint: 'Rechercher une maison, un quartier…',
                  onChanged: (v) => setState(() => _terme = v),
                ),
                const SizedBox(height: AppSpacing.md - AppSpacing.xs),
                AppFilterBar<String>(
                  padding: EdgeInsets.zero,
                  selected: _filtre,
                  onChanged: (v) => setState(() => _filtre = v),
                  options: [
                    AppFilterOption('TOUTES', 'Toutes (${maisons.length})'),
                    AppFilterOption('DISPONIBLES', 'Disponibles (${maisons.where((m) => m.isDisponible).length})',
                        color: AppColors.lotDisponible),
                    AppFilterOption('RESERVEES', 'Réservées (${maisons.where((m) => m.isReserve).length})',
                        color: AppColors.lotReserve),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (liste.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxl),
                    child: EmptyStateView(
                      icon: Icons.home_work_outlined,
                      title: maisons.isEmpty ? 'Aucune maison pour le moment' : 'Aucune maison trouvée',
                      message: maisons.isEmpty
                          ? 'Les maisons clés en main des promoteurs agréés apparaîtront ici.'
                          : 'Aucune maison ne correspond à votre recherche ou au filtre choisi.',
                    ),
                  )
                else
                  for (final m in liste) ...[
                    MaisonCard(maison: m, onTap: () => context.push(ClesEnMainRoutes.detail(m.id))),
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
