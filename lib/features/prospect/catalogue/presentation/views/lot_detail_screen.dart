import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_sizes.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/info_banner.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_booking_sheet.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_rule_banner.dart';

/// Détail d'un lot : même gabarit que la cité et la parcelle.
class LotDetailScreen extends ConsumerStatefulWidget {
  final int lotId;

  const LotDetailScreen({super.key, required this.lotId});

  @override
  ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends ConsumerState<LotDetailScreen> {
  bool _reserving = false;
  bool _annulant = false;

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
      if (lot.programmeId != null) {
        ref.invalidate(lotsByProgrammeProvider(lot.programmeId!));
      }
    }
    if (mounted) setState(() => _reserving = false);
  }

  Future<void> _annuler(ReservationModel r) async {
    setState(() => _annulant = true);
    final ok = await annulerReservationAvecConfirmation(context, ref, r);
    if (ok) ref.invalidate(lotDetailProvider(widget.lotId));
    if (mounted) setState(() => _annulant = false);
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(lotDetailProvider(widget.lotId));
    final mediasAsync = ref.watch(mediasBienProvider(widget.lotId));

    return async.when(
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
          title: 'Lot introuvable',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(lotDetailProvider(widget.lotId)),
        ),
      ),
      data: (lot) {
        final programmeId = lot.programmeId;
        final ProgrammeFoncier? programme = programmeId != null
            ? ref.watch(programmeDetailProvider(programmeId)).valueOrNull
            : null;
        final fam = familleDeStatut(lot.statut);
        final maReservation = maReservationEnAttente(
            ref.watch(mesReservationsProvider).valueOrNull, lot.id);
        final numero =
            (lot.numeroLot ?? '').isNotEmpty ? lot.numeroLot! : '${lot.id}';
        final titre =
            numero.toLowerCase().startsWith('lot') ? numero : 'Lot $numero';
        final hasPlan = programmeId != null &&
            PlanGeometry.parse(lot.geometryJson)?.isPolygon == true;
        final prixM2 =
            (lot.superficie != null && lot.prix != null && lot.superficie! > 0)
                ? lot.prix! / lot.superficie!
                : null;

        return DetailPage(
          title: titre,
          medias: mediasAsync.valueOrNull ?? const [],
          mediasLoading: mediasAsync.isLoading,
          onBack: () => context.pop(),
          onRefresh: () async {
            ref.invalidate(lotDetailProvider(widget.lotId));
            ref.invalidate(mediasBienProvider(widget.lotId));
          },
          bottomBar: DetailActionBar(
            actions: [
              if (maReservation != null)
                DetailButton(
                  label: 'Annuler ma réservation',
                  icon: Icons.close_rounded,
                  danger: true,
                  loading: _annulant,
                  onPressed: () => _annuler(maReservation),
                )
              else if (lot.peutEtreReserve)
                DetailButton(
                  label: 'Réserver ce lot',
                  icon: Icons.bookmark_add_outlined,
                  loading: _reserving,
                  onPressed: () => _reserver(lot),
                ),
              DetailButton(
                label: 'Prendre RDV',
                icon: Icons.event_available_outlined,
                color: AppColors.primaryBlueAnthracite,
                onPressed: () => RdvBookingSheet.show(
                  context,
                  bienId: lot.id,
                  societeId: programme?.societeId,
                  bienLabel: titre,
                  societeNom: programme?.societeNom,
                  chantierLabel: lot.programmeNom,
                ),
              ),
            ],
          ),
          children: [
            DetailHeader(
              title: titre,
              statusLabel: libelleFamille(fam),
              statusColor: couleurFamille(fam),
              subtitle: lot.programmeNom,
              subtitleIcon: Icons.apartment_rounded,
              onSubtitleTap: programmeId == null
                  ? null
                  : () => context.push('/prospect/programmes/$programmeId'),
              tags: [
                if ((lot.reference ?? '').isNotEmpty) 'RÉF : ${lot.reference}',
                if ((lot.numeroIlot ?? '').isNotEmpty)
                  'ÎLOT : ${lot.numeroIlot}',
              ],
            ),
            StatStrip(
              items: [
                StatItem(
                    Icons.square_foot_rounded,
                    lot.superficie != null ? '${_n(lot.superficie!)} m²' : '—',
                    'surface'),
                StatItem(Icons.sell_outlined, CurrencyFormatter.fcfa(lot.prix),
                    'prix de vente',
                    highlight: true),
                if (prixM2 != null)
                  StatItem(Icons.calculate_outlined,
                      CurrencyFormatter.fcfa(prixM2), 'prix au m²'),
              ],
            ),
            DetailSection(
              title: 'Caractéristiques du lot',
              child: InfoRows(
                rows: [
                  (
                    'Surface',
                    lot.superficie != null ? '${_n(lot.superficie!)} m²' : '—'
                  ),
                  if (lot.facade != null) ('Façade', '${_n(lot.facade!)} m'),
                  if (lot.profondeur != null)
                    ('Profondeur', '${_n(lot.profondeur!)} m'),
                  if ((lot.numeroIlot ?? '').isNotEmpty)
                    ('Îlot', lot.numeroIlot!),
                  ('Statut', libelleFamille(fam)),
                ],
              ),
            ),
            if (programme != null)
              DetailSection(
                title: 'Viabilisation',
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
            if (maReservation != null) ...[
              const SizedBox(height: 14),
              InfoBanner.reservationEnAttente(
                  numeroDossier: maReservation.numeroDossier),
            ],
            const SizedBox(height: 14),
            ReservationRuleBanner(
                reservationMultiple: lot.reservationMultiple,
                isReserve: lot.isReserve),
            if (hasPlan) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push(
                    '/prospect/programmes/$programmeId/plan?lot=${lot.id}'),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Voir ce lot sur le plan de masse'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonMedium)),
              ),
            ],
            if (!lot.peutEtreReserve) ...[
              const SizedBox(height: AppSpacing.md - AppSpacing.xs),
              const InfoBanner(
                icone: Icons.block_rounded,
                message: 'Ce lot n\'est pas réservable pour le moment.',
              ),
            ],
          ],
        );
      },
    );
  }
}
