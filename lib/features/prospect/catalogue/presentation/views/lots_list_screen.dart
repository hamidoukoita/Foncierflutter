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
    final prog = ref.watch(programmeDetailProvider(widget.programmeId)).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Lots du programme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            if (prog != null)
              Text(prog.nom, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Voir le plan',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/prospect/programmes/${widget.programmeId}/plan'),
          ),
        ],
      ),
      body: lotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
        error: (e, _) => EmptyStateView(
          icon: Icons.error_outline,
          title: 'Chargement impossible',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(lotsByProgrammeProvider(widget.programmeId)),
        ),
        data: (lots) {
          int count(LotFamille f) => lots.where((l) => familleDeStatut(l.statut) == f).length;
          final visibles = _filtre == null
              ? lots
              : lots.where((l) => familleDeStatut(l.statut) == _filtre).toList();

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  children: [
                    _chip('Tous', null),
                    _chip('Disponibles (${count(LotFamille.libre)})', LotFamille.libre),
                    _chip('Réservés (${count(LotFamille.reserve)})', LotFamille.reserve),
                    _chip('Vendus (${count(LotFamille.vendu)})', LotFamille.vendu),
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
                        onRefresh: () async => ref.invalidate(lotsByProgrammeProvider(widget.programmeId)),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: visibles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _LotCard(
                            lot: visibles[i],
                            onTap: () => context.push('/prospect/lots/${visibles[i].id}'),
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

  Widget _chip(String label, LotFamille? f) {
    final on = _filtre == f;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        showCheckmark: false,
        selectedColor: AppColors.primaryOcre,
        backgroundColor: Colors.white,
        side: BorderSide(color: on ? AppColors.primaryOcre : AppColors.borderLight),
        labelStyle: TextStyle(
          color: on ? Colors.white : AppColors.primaryBlueAnthracite,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
        onSelected: (_) => setState(() => _filtre = f),
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
    final shapes = geo != null && geo.isPolygon ? [PlanLotShape(lot, geo)] : <PlanLotShape>[];

    final details = [
      if (lot.superficie != null) '${lot.superficie!.toStringAsFixed(0)} m²',
      if (lot.prix != null) CurrencyFormatter.fcfa(lot.prix),
    ].join(' • ');

    return Opacity(
      opacity: vendu ? 0.6 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOffWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: shapes.isEmpty
                      ? Icon(Icons.grid_view_rounded, color: color)
                      : PlanMiniature(lots: shapes, showLabels: false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lot.numeroLot != null && lot.numeroLot!.isNotEmpty ? 'Lot ${lot.numeroLot}' : lot.displayRef,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(details, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(libelleFamille(fam),
                            style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
