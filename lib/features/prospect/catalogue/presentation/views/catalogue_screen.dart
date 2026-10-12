import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/widgets/programme_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Catalogue « Cités & Plan » — aligné maquette Figma mobile.
class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final _search = TextEditingController();
  String _query = '';
  /// tous | cites | parcelles
  String _typeTab = 'tous';
  /// null = toutes sociétés
  String? _societe;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ProgrammeFoncier> _applyFilters(List<ProgrammeFoncier> source) {
    var list = source;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((p) =>
              p.nom.toLowerCase().contains(q) ||
              (p.lieu ?? '').toLowerCase().contains(q) ||
              (p.societeNom ?? '').toLowerCase().contains(q))
          .toList();
    }
    if (_societe != null) {
      list = list
          .where((p) =>
              (p.societeNom ?? '').toLowerCase() == _societe!.toLowerCase())
          .toList();
    }
    // Parcelles : pas de programmes (onglet distinct ailleurs)
    if (_typeTab == 'parcelles') {
      return [];
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(programmesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOcre),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: AppColors.grey400),
                const SizedBox(height: 12),
                Text('$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(programmesProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (programmes) {
          final societes = programmes
              .map((p) => p.societeNom?.trim() ?? '')
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filtered = _applyFilters(programmes);

          return RefreshIndicator(
            color: AppColors.primaryOcre,
            onRefresh: () async => ref.invalidate(programmesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre page (Figma)
                        const Text(
                          'Cités & Plan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlueAnthracite,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppSearchField(
                          controller: _search,
                          hint: 'Rechercher une zone (Kati, Safo, Sanankoroba…)',
                          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppFilterBar<String>(
                        selected: _typeTab,
                        onChanged: (v) => setState(() => _typeTab = v),
                        options: const [
                          AppFilterOption('tous', 'Tous'),
                          AppFilterOption('cites', 'Cités'),
                          AppFilterOption('parcelles', 'Parcelles'),
                        ],
                      ),
                      if (societes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        AppFilterBar<String?>(
                          selected: _societe,
                          onChanged: (v) => setState(() => _societe = v),
                          options: [
                            const AppFilterOption<String?>(null, 'Toutes les sociétés', color: AppColors.primaryBlueAnthracite),
                            for (final s in societes)
                              AppFilterOption<String?>(s, s, color: AppColors.primaryBlueAnthracite),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                if (_typeTab == 'parcelles')
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateView(
                      icon: Icons.grid_view_rounded,
                      title: 'Parcelles individuelles',
                      message:
                          'Retrouvez les parcelles dans l’onglet Parcelles de la barre de navigation.',
                    ),
                  )
                else if (programmes.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateView(
                      icon: Icons.map_outlined,
                      title: 'Aucun programme',
                      message: 'Aucun programme foncier publié pour le moment.',
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'Aucun résultat',
                        message:
                            'Aucun programme ne correspond à vos filtres.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final p = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ProgrammeCard(
                              programme: p,
                              onTap: () =>
                                  context.push('/prospect/programmes/${p.id}'),
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
