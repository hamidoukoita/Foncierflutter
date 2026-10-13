import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/widgets/programme_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/shell/widgets/prospect_account_menu.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/page_header.dart';

/// Catalogue « Cités & Plan » : recherche par zone et filtre par promoteur.
/// (Les parcelles individuelles ont leur propre onglet.)
class CatalogueScreen extends ConsumerStatefulWidget {
  final String? zoneInitiale;

  const CatalogueScreen({super.key, this.zoneInitiale});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  late final TextEditingController _search =
      TextEditingController(text: widget.zoneInitiale ?? '');
  late String _query = (widget.zoneInitiale ?? '').toLowerCase();

  /// null = toutes les sociétés
  String? _societe;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ProgrammeFoncier> _filtrer(List<ProgrammeFoncier> source) {
    return source.where((p) {
      final correspondRecherche = _query.isEmpty ||
          p.nom.toLowerCase().contains(_query) ||
          (p.lieu ?? '').toLowerCase().contains(_query) ||
          (p.societeNom ?? '').toLowerCase().contains(_query);
      final correspondSociete = _societe == null ||
          (p.societeNom ?? '').toLowerCase() == _societe!.toLowerCase();
      return correspondRecherche && correspondSociete;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(programmesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyStateView(
            icon: Icons.cloud_off_rounded,
            title: 'Catalogue indisponible',
            message: ErrorHandler.messageOf(e),
            onRetry: () => ref.invalidate(programmesProvider),
          ),
          data: (programmes) => _contenu(programmes),
        ),
      ),
    );
  }

  Widget _contenu(List<ProgrammeFoncier> programmes) {
    final societes = programmes
        .map((p) => p.societeNom?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final resultats = _filtrer(programmes);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(programmesProvider),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Cités & Plan',
                    subtitle: '${programmes.length} cités de promoteurs agréés',
                    trailing: const ProspectAccountMenu(),
                  ),
                  const SizedBox(height: AppSpacing.md + AppSpacing.xs),
                  AppSearchField(
                    controller: _search,
                    hint: 'Rechercher une zone (Kati, Yirimadio, Sanankoroba…)',
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                ],
              ),
            ),
          ),
          if (societes.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppFilterBar<String?>(
                  selected: _societe,
                  onChanged: (v) => setState(() => _societe = v),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal),
                  options: [
                    const AppFilterOption<String?>(null, 'Tous les promoteurs',
                        color: AppColors.primaryBlueAnthracite),
                    for (final s in societes)
                      AppFilterOption<String?>(s, s,
                          color: AppColors.primaryBlueAnthracite),
                  ],
                ),
              ),
            ),
          if (programmes.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.map_outlined,
                title: 'Aucune cité publiée',
                message: 'Les cités des promoteurs agréés apparaîtront ici.',
              ),
            )
          else if (resultats.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.search_off_rounded,
                title: 'Aucun résultat',
                message: 'Aucune cité ne correspond à votre recherche.',
                retryLabel: 'Effacer la recherche',
                onRetry: () => setState(() {
                  _search.clear();
                  _query = '';
                  _societe = null;
                }),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.sm,
                AppSpacing.pageHorizontal,
                AppSpacing.lg,
              ),
              sliver: SliverList.separated(
                itemCount: resultats.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final p = resultats[index];
                  return ProgrammeCard(
                    programme: p,
                    onTap: () => context.push('/prospect/programmes/${p.id}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
