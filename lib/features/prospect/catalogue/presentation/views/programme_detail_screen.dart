import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/domain/lieu_carte_builder.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/localisation_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/presentation/widgets/localisation_preview_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/presentation/controllers/localisation_providers.dart';
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
    final proximites =
        ref.watch(proximitesProgrammeProvider(programmeId)).valueOrNull ??
            const [];

    return progAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryOcre)),
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
        final lotsCount =
            lots.isNotEmpty ? lots.length : (programme.totalLots ?? 0);
        final progress = ((programme.avancement ?? 0).clamp(0, 100)) / 100.0;
        final prix = lots
            .where((l) => (l.prix ?? 0) > 0)
            .map((l) => l.prix!)
            .toList()
          ..sort();
        final surfaceHa = programme.superficieTotale != null
            ? (programme.superficieTotale! / 10000)
                .toStringAsFixed(programme.superficieTotale! >= 10000 ? 0 : 1)
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
                label: 'Localisation',
                icon: Icons.place_rounded,
                color: AppColors.primaryBlueAnthracite,
                onPressed: () =>
                    context.push(LocalisationRoutes.programme(programmeId)),
              ),
              DetailButton(
                label: 'Voir les lots',
                icon: Icons.grid_view_rounded,
                onPressed: () =>
                    context.push('/prospect/programmes/$programmeId/lots'),
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
                if ((programme.societeNom ?? '').isNotEmpty)
                  programme.societeNom!,
              ].join(' • '),
              tags: [
                if ((programme.numeroTitreMere ?? '').isNotEmpty)
                  'TF MÈRE : ${programme.numeroTitreMere}',
              ],
            ),
            StatStrip(
              items: [
                StatItem(Icons.grid_view_rounded, '$lotsCount', 'lots'),
                if (surfaceHa != null)
                  StatItem(
                      Icons.terrain_outlined, '$surfaceHa ha', 'superficie'),
                StatItem(
                  Icons.sell_outlined,
                  prix.isEmpty
                      ? 'Sur devis'
                      : CurrencyFormatter.fcfa(prix.first),
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
                  style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.55, color: AppColors.primaryBlueAnthracite),
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
                      Text('Progression', style: AppTextStyles.bodyMedium),
                      Text('${programme.avancement ?? 0}%',
                          style: AppTextStyles.cardTitle
                              .copyWith(color: AppColors.successGreen)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.radiusRound,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.successGreenSoft,
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
                    subtitle: programme.eauSomapep == true
                        ? 'Raccordé'
                        : 'Non raccordé',
                    ok: programme.eauSomapep == true,
                  ),
                  FeatureTile(
                    icon: Icons.bolt_outlined,
                    title: 'Réseau EDM',
                    subtitle: programme.electriciteEdm == true
                        ? 'Disponible'
                        : 'Non raccordé',
                    ok: programme.electriciteEdm == true,
                  ),
                  FeatureTile(
                    icon: Icons.alt_route_rounded,
                    title: 'Voirie',
                    subtitle: programme.voirieBitumee == true
                        ? 'Bitumée'
                        : 'Non bitumée',
                    ok: programme.voirieBitumee == true,
                  ),
                ],
              ),
            ),
            DetailSection(
              title: 'Localisation',
              child: LocalisationPreviewCard(
                lieu: LieuCarteBuilder.pourProgramme(
                  programme,
                  lots: lots,
                  proximites: proximites,
                ),
                onOuvrir: () =>
                    context.push(LocalisationRoutes.programme(programmeId)),
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
                elements: planAsync.valueOrNull?.elements
                        .where((e) => e.visible)
                        .toList() ??
                    const [],
                lotsCount: lots.length,
                onOpenPlan: () =>
                    context.push('/prospect/programmes/$programmeId/plan'),
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
    if (s.contains('VENIR') || s.contains('BROUILLON')) {
      return ('À venir', AppColors.warningAmber);
    }
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
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.4,
      children: items
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xxs,
                  vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.backgroundOffWhite,
                borderRadius: AppRadius.radiusLg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOcreSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconePourElement(e.type),
                        size: 18, color: AppColors.primaryOcre),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.affichage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Dans le lotissement',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryOcre,
                              fontWeight: FontWeight.w600),
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
        borderRadius: AppRadius.radiusLg,
        child: Container(
          height: 190,
          width: double.infinity,
          color: AppColors.backgroundOffWhite,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (lots.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Le plan de masse n\'a pas encore été publié par la société.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: PlanMiniature(
                      lots: lots, elements: elements, showLabels: false),
                ),
              if (lots.isNotEmpty)
                Positioned(
                  right: AppSpacing.md - AppSpacing.xs,
                  bottom: AppSpacing.md - AppSpacing.xs,
                  child: AppActionButton(
                    label: 'Voir le plan de masse',
                    icon: Icons.map_outlined,
                    variant: AppActionVariant.dark,
                    height: 36,
                    onPressed: onOpenPlan,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
