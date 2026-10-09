import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/widgets/programme_card.dart';
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
                        // Recherche
                        _SearchBar(
                          controller: _search,
                          onChanged: (v) =>
                              setState(() => _query = v.trim().toLowerCase()),
                        ),
                        const SizedBox(height: 14),
                        // Tabs type
                        Row(
                          children: [
                            Expanded(
                              child: _TypeChip(
                                label: 'Tous',
                                selected: _typeTab == 'tous',
                                filled: true,
                                onTap: () => setState(() => _typeTab = 'tous'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TypeChip(
                                label: 'Cités',
                                selected: _typeTab == 'cites',
                                onTap: () => setState(() => _typeTab = 'cites'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TypeChip(
                                label: 'Parcelles',
                                selected: _typeTab == 'parcelles',
                                onTap: () =>
                                    setState(() => _typeTab = 'parcelles'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Sociétés
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'SOCIÉTÉS :',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.grey500,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _SocietyChip(
                                      label: 'Toutes',
                                      selected: _societe == null,
                                      onTap: () =>
                                          setState(() => _societe = null),
                                    ),
                                    ...societes.map(
                                      (s) => Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: _SocietyChip(
                                          label: s,
                                          selected: _societe == s,
                                          onTap: () =>
                                              setState(() => _societe = s),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryBlueAnthracite,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher une zone (Kati, Safo, Sanankoroba…)',
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppColors.grey500.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.searchIcon, size: 22),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.backgroundOffWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded,
                color: AppColors.primaryBlueAnthracite, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.filled = false /* reserved */,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryOcre : AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.primaryOcre : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primaryBlueAnthracite,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocietyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SocietyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryBlueAnthracite : AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlueAnthracite
                  : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primaryBlueAnthracite,
            ),
          ),
        ),
      ),
    );
  }
}
