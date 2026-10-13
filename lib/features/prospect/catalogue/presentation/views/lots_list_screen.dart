import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/presentation/widgets/plan_masse_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// « Lots du programme » : liste filtrable (Tous / Disponibles / Réservés / Vendus).
class LotsListScreen extends ConsumerStatefulWidget {
  final int programmeId;
  const LotsListScreen({super.key, required this.programmeId});

  @override
  ConsumerState<LotsListScreen> createState() => _LotsListScreenState();
}

class _LotsListScreenState extends ConsumerState<LotsListScreen> {
  LotFamille? _filtre;

  @override
  Widget build(BuildContext context) {
    final lotsAsync = ref.watch(lotsByProgrammeProvider(widget.programmeId));
    final prog =
        ref.watch(programmeDetailProvider(widget.programmeId)).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Column(
          children: [
            Text('Lots du programme', style: AppTextStyles.h3),
            if (prog != null) Text(prog.nom, style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Voir le plan',
            icon: const Icon(Icons.map_outlined),
            onPressed: () =>
                context.push('/prospect/programmes/${widget.programmeId}/plan'),
          ),
        ],
      ),
      body: lotsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOcre)),
        error: (e, _) => EmptyStateView(
          icon: Icons.error_outline,
          title: 'Chargement impossible',
          message: ErrorHandler.messageOf(e),
          onRetry: () =>
              ref.invalidate(lotsByProgrammeProvider(widget.programmeId)),
        ),
        data: (lots) {
          int count(LotFamille f) =>
              lots.where((l) => familleDeStatut(l.statut) == f).length;
          final visibles = _filtre == null
              ? lots
              : lots
                  .where((l) => familleDeStatut(l.statut) == _filtre)
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AppFilterBar<LotFamille?>(
                  selected: _filtre,
                  onChanged: (v) => setState(() => _filtre = v),
                  options: [
                    const AppFilterOption<LotFamille?>(null, 'Tous'),
                    AppFilterOption<LotFamille?>(LotFamille.libre,
                        'Disponibles (${count(LotFamille.libre)})',
                        color: couleurFamille(LotFamille.libre)),
                    AppFilterOption<LotFamille?>(LotFamille.reserve,
                        'Réservés (${count(LotFamille.reserve)})',
                        color: couleurFamille(LotFamille.reserve)),
                    AppFilterOption<LotFamille?>(
                        LotFamille.vendu, 'Vendus (${count(LotFamille.vendu)})',
                        color: couleurFamille(LotFamille.vendu)),
                  ],
                ),
              ),
              Expanded(
                child: visibles.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.grid_view_rounded,
                        title: 'Aucun lot',
                        message: 'Aucun lot ne correspond à ce filtre.',
                      )
                    : RefreshIndicator(
                        color: AppColors.primaryOcre,
                        onRefresh: () async => ref.invalidate(
                            lotsByProgrammeProvider(widget.programmeId)),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: visibles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _LotCard(
                            lot: visibles[i],
                            onTap: () => context
                                .push('/prospect/lots/${visibles[i].id}'),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final LotProgramme lot;
  final VoidCallback onTap;
  const _LotCard({required this.lot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fam = familleDeStatut(lot.statut);
    final color = couleurFamille(fam);
    final vendu = fam == LotFamille.vendu;
    final geo = PlanGeometry.parse(lot.geometryJson);
    final shapes = geo != null && geo.isPolygon
        ? [PlanLotShape(lot, geo)]
        : <PlanLotShape>[];

    final details = [
      if (lot.superficie != null) '${lot.superficie!.toStringAsFixed(0)} m²',
      if (lot.prix != null) CurrencyFormatter.fcfa(lot.prix),
    ].join(' • ');

    return Opacity(
      opacity: vendu ? 0.6 : 1,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
              decoration: const BoxDecoration(
                color: AppColors.backgroundOffWhite,
                borderRadius: AppRadius.radiusMd,
              ),
              child: shapes.isEmpty
                  ? Icon(Icons.grid_view_rounded, color: color)
                  : PlanMiniature(lots: shapes, showLabels: false),
            ),
            const SizedBox(width: AppSpacing.md - AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lot.numeroLot != null && lot.numeroLot!.isNotEmpty
                        ? 'Lot ${lot.numeroLot}'
                        : lot.displayRef,
                    style: AppTextStyles.cardTitle,
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(details, style: AppTextStyles.bodySmall),
                  ],
                  const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                  StatusPill(label: libelleFamille(fam), color: color),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}
