import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/presentation/widgets/plan_masse_view.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Plan de masse d'une cité : on touche un lot pour voir sa fiche, et on peut le réserver directement
/// lorsqu'il est disponible (vert).
class PlanMasseScreen extends ConsumerStatefulWidget {
  final int programmeId;
  final int? initialLotId;

  const PlanMasseScreen({super.key, required this.programmeId, this.initialLotId});

  @override
  ConsumerState<PlanMasseScreen> createState() => _PlanMasseScreenState();
}

class _PlanMasseScreenState extends ConsumerState<PlanMasseScreen> {
  int? _selectedId;
  LotFamille? _filtre;
  bool _reserving = false;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialLotId;
  }

  Future<void> _reserver(LotProgramme lot) async {
    setState(() => _reserving = true);
    final ok = await reserverBienAvecConfirmation(
      context,
      ref,
      bienId: lot.id,
      libelle: lot.displayRef,
    );
    if (ok) {
      ref.invalidate(lotsByProgrammeProvider(widget.programmeId));
      ref.invalidate(lotDetailProvider(lot.id));
    }
    if (mounted) setState(() => _reserving = false);
  }

  @override
  Widget build(BuildContext context) {
    final progAsync = ref.watch(programmeDetailProvider(widget.programmeId));
    final lotsAsync = ref.watch(lotsByProgrammeProvider(widget.programmeId));
    final planAsync = ref.watch(planMasseProvider(widget.programmeId));
    final programme = progAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text(
          programme != null ? 'Plan de masse : ${programme.nom}' : 'Plan de masse',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
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
          final shapes = lotsAvecGeometrie(lots);
          if (shapes.isEmpty) {
            return EmptyStateView(
              icon: Icons.map_outlined,
              title: 'Plan non disponible',
              message: lots.isEmpty
                  ? 'Aucun lot n\'a encore été publié pour cette cité.'
                  : 'La société n\'a pas encore dessiné le plan de masse. Vous pouvez consulter la liste des lots.',
            );
          }
          final elements = (planAsync.valueOrNull?.elements ?? const <PlanElement>[])
              .where((e) => e.visible)
              .toList()
            ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

          int count(LotFamille f) => shapes.where((s) => s.famille == f).length;
          LotProgramme? selected;
          for (final s in shapes) {
            if (s.lot.id == _selectedId) selected = s.lot;
          }

          return Column(
            children: [
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                  children: [
                    _chip('Tous (${shapes.length})', null, AppColors.primaryBlueAnthracite),
                    for (final f in [LotFamille.libre, LotFamille.reserve, LotFamille.vendu])
                      _chip('${libelleFamille(f) == 'Disponible' ? 'Libre' : libelleFamille(f)} (${count(f)})', f,
                          couleurFamille(f)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: ColoredBox(
                      color: const Color(0xFFEFEBE0),
                      child: PlanMasseView(
                        lots: shapes,
                        elements: elements,
                        selectedLotId: _selectedId,
                        filtre: _filtre,
                        onLotTap: (lot) => setState(() => _selectedId = lot?.id),
                      ),
                    ),
                  ),
                ),
              ),
              if (selected != null)
                _LotPanel(
                  lot: selected,
                  programme: programme,
                  reserving: _reserving,
                  onReserver: () => _reserver(selected!),
                  onDetails: () => context.push('/prospect/lots/${selected!.id}'),
                )
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 12 + MediaQuery.of(context).padding.bottom),
                  child: const Text(
                    'Touchez un lot pour voir sa fiche. Les lots verts sont disponibles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, LotFamille? f, Color color) {
    final on = _filtre == f;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        showCheckmark: false,
        selectedColor: color,
        backgroundColor: Colors.white,
        side: BorderSide(color: on ? color : AppColors.borderLight),
        labelStyle: TextStyle(
          color: on ? Colors.white : AppColors.primaryBlueAnthracite,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
        avatar: f == null || on
            ? null
            : CircleAvatar(radius: 5, backgroundColor: color),
        onSelected: (_) => setState(() => _filtre = f),
      ),
    );
  }
}

class _LotPanel extends StatelessWidget {
  final LotProgramme lot;
  final ProgrammeFoncier? programme;
  final bool reserving;
  final VoidCallback onReserver;
  final VoidCallback onDetails;

  const _LotPanel({
    required this.lot,
    required this.programme,
    required this.reserving,
    required this.onReserver,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final fam = familleDeStatut(lot.statut);
    final color = couleurFamille(fam);
    final dims = (lot.facade != null && lot.profondeur != null)
        ? '${_n(lot.facade!)} × ${_n(lot.profondeur!)} m'
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, -3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lot.numeroLot != null && lot.numeroLot!.isNotEmpty ? 'Lot N° ${lot.numeroLot}' : lot.displayRef,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  libelleFamille(fam),
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              if (lot.superficie != null) _info(Icons.square_foot_rounded, '${_n(lot.superficie!)} m²'),
              if (dims != null) _info(Icons.straighten_rounded, dims),
              if (programme?.eauSomapep == true) _info(Icons.water_drop_outlined, 'SOMAPEP'),
              if (programme?.electriciteEdm == true) _info(Icons.bolt_outlined, 'EDM'),
            ],
          ),
          if (lot.prix != null) ...[
            const SizedBox(height: 10),
            const Text('Prix de vente officiel',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            Text(
              CurrencyFormatter.fcfa(lot.prix!),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryOcre),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (lot.peutEtreReserve) ...[
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: reserving ? null : onReserver,
                      icon: reserving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('Réserver', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOcre,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Visualiser les détails', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData i, String t) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 16, color: AppColors.grey500),
          const SizedBox(width: 4),
          Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      );

  static String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
