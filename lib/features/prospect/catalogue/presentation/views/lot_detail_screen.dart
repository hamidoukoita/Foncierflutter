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
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_booking_sheet.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/hero_media.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_rule_banner.dart';

/// Détail d'un lot : visuels (photos / 360°), identité, caractéristiques, règle de réservation, actions.
class LotDetailScreen extends ConsumerStatefulWidget {
  final int lotId;

  const LotDetailScreen({super.key, required this.lotId});

  @override
  ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends ConsumerState<LotDetailScreen> {
  bool _reserving = false;

  Future<void> _reserver(LotProgramme lot) async {
    setState(() => _reserving = true);
    final ok = await reserverBienAvecConfirmation(
      context,
      ref,
      bienId: widget.lotId,
      libelle: lot.displayRef,
    );
    if (ok) {
      ref.invalidate(lotDetailProvider(widget.lotId));
      if (lot.programmeId != null) ref.invalidate(lotsByProgrammeProvider(lot.programmeId!));
    }
    if (mounted) setState(() => _reserving = false);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(lotDetailProvider(widget.lotId));
    final mediasAsync = ref.watch(mediasBienProvider(widget.lotId));

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
        error: (e, _) => SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(ErrorHandler.messageOf(e), textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (lot) {
          final programmeId = lot.programmeId;
          final ProgrammeFoncier? programme =
              programmeId != null ? ref.watch(programmeDetailProvider(programmeId)).valueOrNull : null;
          final fam = familleDeStatut(lot.statut);
          final color = couleurFamille(fam);
          final hasPlan = programmeId != null && PlanGeometry.parse(lot.geometryJson)?.isPolygon == true;
          final numero = (lot.numeroLot ?? '').isNotEmpty ? lot.numeroLot! : '${lot.id}';

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    DetailSliverAppBar(
                      title: 'Lot $numero',
                      medias: mediasAsync.valueOrNull ?? const [],
                      loading: mediasAsync.isLoading,
                      onBack: () => context.pop(),
                    ),
                    SliverToBoxAdapter(
                      child:
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Lot $numero',
                                        style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryBlueAnthracite),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(libelleFamille(fam),
                                          style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                if (lot.programmeNom != null) ...[
                                  const SizedBox(height: 2),
                                  Text(lot.programmeNom!,
                                      style: const TextStyle(
                                          color: AppColors.primaryOcre, fontWeight: FontWeight.w700, fontSize: 13)),
                                ],
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if ((lot.reference ?? '').isNotEmpty) _tag('RÉF : ${lot.reference}'),
                                    if ((lot.numeroIlot ?? '').isNotEmpty) _tag('ÎLOT : ${lot.numeroIlot}'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (lot.superficie != null)
                                      _pill(Icons.square_foot_rounded, '${_n(lot.superficie!)} m²',
                                          AppColors.backgroundOffWhite, AppColors.primaryBlueAnthracite),
                                    if (lot.prix != null)
                                      _pill(Icons.sell_outlined, CurrencyFormatter.fcfa(lot.prix),
                                          const Color(0xFFFFF1C9), const Color(0xFF8A5A00)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Caractéristiques du lot',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryBlueAnthracite)),
                                const SizedBox(height: 12),
                                _line('Surface', lot.superficie != null ? '${_n(lot.superficie!)} m²' : '—'),
                                if (lot.facade != null) _line('Façade', '${_n(lot.facade!)} m'),
                                if (lot.profondeur != null) _line('Profondeur', '${_n(lot.profondeur!)} m'),
                                if (lot.superficie != null && lot.prix != null && lot.superficie! > 0)
                                  _line('Prix au m²', CurrencyFormatter.fcfa(lot.prix! / lot.superficie!)),
                                if ((lot.numeroIlot ?? '').isNotEmpty) _line('Îlot', lot.numeroIlot!),
                                if (programme != null) ...[
                                  _line('Eau potable (SOMAPEP)', programme.eauSomapep == true ? 'Raccordé' : 'Non raccordé'),
                                  _line('Électricité (EDM)', programme.electriciteEdm == true ? 'Disponible' : 'Non raccordé'),
                                  _line('Voirie', programme.voirieBitumee == true ? 'Bitumée' : 'Non bitumée'),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          ReservationRuleBanner(
                              reservationMultiple: lot.reservationMultiple, isReserve: lot.isReserve),
                          if (hasPlan) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  context.push('/prospect/programmes/$programmeId/plan?lot=${lot.id}'),
                              icon: const Icon(Icons.map_outlined, size: 18),
                              label: const Text('Voir ce lot sur le plan de masse'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlueAnthracite,
                                side: const BorderSide(color: AppColors.borderLight),
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ],
                          if (!lot.peutEtreReserve) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Ce lot n\'est pas réservable pour le moment.',
                                  style: TextStyle(color: AppColors.grey600)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    if (lot.peutEtreReserve) ...[
                      Expanded(
                        child: _action(
                          _reserving ? 'Réservation…' : 'Réserver ce lot',
                          AppColors.primaryOcre,
                          _reserving ? null : () => _reserver(lot),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: _action(
                        'Prendre RDV',
                        AppColors.primaryBlueAnthracite,
                        () => RdvBookingSheet.show(
                          context,
                          bienId: lot.id,
                          societeId: programme?.societeId,
                          bienLabel: '${lot.displayRef}${lot.programmeNom != null ? ' · ${lot.programmeNom}' : ''}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _action(String text, Color bg, VoidCallback? onTap) => SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
        ),
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: child,
      );

  Widget _tag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.backgroundOffWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(t,
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryBlueAnthracite)),
      );

  Widget _pill(IconData i, String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(i, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(t, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13.5)),
          ],
        ),
      );

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      );

  static String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
