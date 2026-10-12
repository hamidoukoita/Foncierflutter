import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/presentation/widgets/plan_masse_view.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Détail d'une cité / programme.
class ProgrammeDetailScreen extends ConsumerWidget {
  final int programmeId;

  const ProgrammeDetailScreen({super.key, required this.programmeId});

  /// Équipements réellement dessinés sur le plan (aucune donnée inventée).
  static List<PlanElement> _commodites(PlanMasse? plan) {
    if (plan == null) return const [];
    final vus = <String>{};
    final out = <PlanElement>[];
    for (final e in plan.elements) {
      if (!e.visible || e.isRoute || e.type == 'ESPACE_VERT') continue;
      if (vus.add('${e.type}|${e.nom ?? ''}')) out.add(e);
    }
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progAsync = ref.watch(programmeDetailProvider(programmeId));
    final lotsAsync = ref.watch(lotsByProgrammeProvider(programmeId));
    final mediasAsync = ref.watch(programmeMediasProvider(programmeId));
    final planAsync = ref.watch(planMasseProvider(programmeId));

    return progAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        appBar: AppBar(),
        body: EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Cité introuvable',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(programmeDetailProvider(programmeId)),
        ),
      ),
      data: (programme) {
        final lots = lotsAsync.valueOrNull ?? <LotProgramme>[];
        final lotsCount = lots.isNotEmpty ? lots.length : (programme.totalLots ?? 0);
        final progress = ((programme.avancement ?? 0).clamp(0, 100)) / 100.0;
        final prix = lots.where((l) => (l.prix ?? 0) > 0).map((l) => l.prix!).toList()..sort();
        final surfaceHa = programme.superficieTotale != null
            ? (programme.superficieTotale! / 10000).toStringAsFixed(programme.superficieTotale! >= 10000 ? 0 : 1)
            : null;
        final status = _status(programme.statut);
        final commodites = _commodites(planAsync.valueOrNull);

        return DetailPage(
          title: programme.nom,
          medias: mediasAsync.valueOrNull ?? const [],
          mediasLoading: mediasAsync.isLoading,
          onBack: () => context.pop(),
          onRefresh: () async {
            ref.invalidate(programmeDetailProvider(programmeId));
            ref.invalidate(lotsByProgrammeProvider(programmeId));
            ref.invalidate(planMasseProvider(programmeId));
            ref.invalidate(programmeMediasProvider(programmeId));
          },
          bottomBar: DetailActionBar(
            actions: [
              DetailButton(
                label: 'Voir le plan',
                icon: Icons.map_outlined,
                color: AppColors.primaryBlueAnthracite,
                onPressed: () => context.push('/prospect/programmes/$programmeId/plan'),
              ),
              DetailButton(
                label: 'Voir les lots',
                icon: Icons.grid_view_rounded,
                onPressed: () => context.push('/prospect/programmes/$programmeId/lots'),
              ),
            ],
          ),
          children: [
            DetailHeader(
              title: programme.nom,
              statusLabel: status.$1,
              statusColor: status.$2,
              subtitle: [
                if ((programme.lieu ?? '').isNotEmpty) programme.lieu!,
                if ((programme.societeNom ?? '').isNotEmpty) programme.societeNom!,
              ].join(' • '),
              tags: [
                if ((programme.numeroTitreMere ?? '').isNotEmpty) 'TF MÈRE : ${programme.numeroTitreMere}',
              ],
            ),
            StatStrip(
              items: [
                StatItem(Icons.grid_view_rounded, '$lotsCount', 'lots'),
                if (surfaceHa != null) StatItem(Icons.terrain_outlined, '$surfaceHa ha', 'superficie'),
                StatItem(
                  Icons.sell_outlined,
                  prix.isEmpty ? 'Sur devis' : CurrencyFormatter.fcfa(prix.first),
                  prix.isEmpty ? 'prix' : 'à partir de',
                  highlight: true,
                ),
              ],
            ),
            if ((programme.description ?? '').trim().isNotEmpty)
              DetailSection(
                title: 'À propos',
                child: Text(
                  programme.description!.trim(),
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.primaryBlueAnthracite),
                ),
              ),
            DetailSection(
              title: 'Avancement des travaux',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progression', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('${programme.avancement ?? 0}%',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryBlueAnthracite)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.grey200,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ),
            DetailSection(
              title: 'Viabilisation du site (VRD)',
              child: FeatureRow(
                tiles: [
                  FeatureTile(
                    icon: Icons.water_drop_outlined,
                    title: 'Eau potable',
                    subtitle: programme.eauSomapep == true ? 'Raccordé' : 'Non raccordé',
                    ok: programme.eauSomapep == true,
                  ),
                  FeatureTile(
                    icon: Icons.bolt_outlined,
                    title: 'Réseau EDM',
                    subtitle: programme.electriciteEdm == true ? 'Disponible' : 'Non raccordé',
                    ok: programme.electriciteEdm == true,
                  ),
                  FeatureTile(
                    icon: Icons.alt_route_rounded,
                    title: 'Voirie',
                    subtitle: programme.voirieBitumee == true ? 'Bitumée' : 'Non bitumée',
                    ok: programme.voirieBitumee == true,
                  ),
                ],
              ),
            ),
            if (commodites.isNotEmpty)
              DetailSection(
                title: 'Commodités du lotissement',
                child: _CommoditesGrid(items: commodites),
              ),
            DetailSection(
              title: 'Plan de masse',
              child: _PlanPreview(
                lots: lotsAvecGeometrie(lots),
                elements: planAsync.valueOrNull?.elements.where((e) => e.visible).toList() ?? const [],
                lotsCount: lots.length,
                onOpenPlan: () => context.push('/prospect/programmes/$programmeId/plan'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// label, couleur
  static (String, Color) _status(String? statut) {
    final s = (statut ?? '').toUpperCase();
    if (s.contains('VENIR') || s.contains('BROUILLON')) return ('À venir', AppColors.warningAmber);
    return ('En cours', AppColors.successGreen);
  }
}

IconData _iconePourElement(String type) {
  switch (type) {
    case 'MOSQUEE':
      return Icons.mosque_outlined;
    case 'EGLISE':
      return Icons.church_outlined;
    case 'ECOLE':
      return Icons.school_outlined;
    case 'MARCHE':
      return Icons.storefront_outlined;
    case 'COMMERCE':
      return Icons.shopping_bag_outlined;
    case 'EQUIPEMENT_PUBLIC':
      return Icons.account_balance_outlined;
    default:
      return Icons.place_outlined;
  }
}

class _CommoditesGrid extends StatelessWidget {
  final List<PlanElement> items;
  const _CommoditesGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: items
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundOffWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_iconePourElement(e.type), size: 18, color: AppColors.primaryOcre),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.affichage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                        const Text(
                          'Dans le lotissement',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryOcre,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlanPreview extends StatelessWidget {
  final List<PlanLotShape> lots;
  final List<PlanElement> elements;
  final int lotsCount;
  final VoidCallback onOpenPlan;

  const _PlanPreview({
    required this.lots,
    required this.elements,
    required this.lotsCount,
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: lots.isEmpty ? null : onOpenPlan,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          width: double.infinity,
          color: const Color(0xFFF8F7F2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (lots.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Le plan de masse n\'a pas encore été publié par la société.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlanMiniature(lots: lots, elements: elements, showLabels: false),
                ),
              if (lots.isNotEmpty)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: onOpenPlan,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          'Voir le plan ›',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
