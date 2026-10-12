import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_booking_sheet.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_rule_banner.dart';

/// Fiche d'une parcelle individuelle : même gabarit que la cité et le lot.
class ProspectParcelleDetailScreen extends ConsumerStatefulWidget {
  final int parcelleId;

  const ProspectParcelleDetailScreen({super.key, required this.parcelleId});

  @override
  ConsumerState<ProspectParcelleDetailScreen> createState() => _ProspectParcelleDetailScreenState();
}

class _ProspectParcelleDetailScreenState extends ConsumerState<ProspectParcelleDetailScreen> {
  bool _reserving = false;
  bool _annulant = false;

  Future<void> _reserver(BienFoncierModel b) async {
    setState(() => _reserving = true);
    await reserverBienAvecConfirmation(context, ref, bienId: b.id, libelle: b.designation);
    if (mounted) setState(() => _reserving = false);
  }

  Future<void> _annuler(ReservationModel r) async {
    setState(() => _annulant = true);
    final ok = await annulerReservationAvecConfirmation(context, ref, r);
    if (ok) ref.invalidate(bienDetailProvider(widget.parcelleId));
    if (mounted) setState(() => _annulant = false);
  }

  static String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bienDetailProvider(widget.parcelleId));
    final mediasAsync = ref.watch(mediasBienProvider(widget.parcelleId));

    return async.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        appBar: AppBar(),
        body: EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Parcelle introuvable',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(bienDetailProvider(widget.parcelleId)),
        ),
      ),
      data: (b) {
        final fam = familleDeStatut(b.statut);
        final maReservation = maReservationEnAttente(ref.watch(mesReservationsProvider).valueOrNull, b.id);
        final prixM2 = b.superficie > 0 ? b.prix / b.superficie : null;

        return DetailPage(
          title: b.designation,
          medias: mediasAsync.valueOrNull ?? const [],
          mediasLoading: mediasAsync.isLoading,
          onBack: () => context.pop(),
          onRefresh: () async {
            ref.invalidate(bienDetailProvider(widget.parcelleId));
            ref.invalidate(mediasBienProvider(widget.parcelleId));
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
              else if (b.peutEtreReserve)
                DetailButton(
                  label: 'Réserver',
                  icon: Icons.bookmark_add_outlined,
                  loading: _reserving,
                  onPressed: () => _reserver(b),
                ),
              DetailButton(
                label: 'Prendre RDV',
                icon: Icons.event_available_outlined,
                color: AppColors.primaryBlueAnthracite,
                onPressed: () => RdvBookingSheet.show(
                  context,
                  bienId: b.id,
                  societeId: b.societeId,
                  bienLabel: b.designation,
                  societeNom: b.societeNom,
                  chantierLabel: b.localisation,
                ),
              ),
            ],
          ),
          children: [
            DetailHeader(
              title: b.designation,
              statusLabel: libelleFamille(fam),
              statusColor: couleurFamille(fam),
              subtitle: b.societeNom,
              subtitleIcon: Icons.business_rounded,
              tags: [
                if ((b.numeroTitreFoncier ?? '').isNotEmpty) 'TF : ${b.numeroTitreFoncier}',
              ],
            ),
            StatStrip(
              items: [
                StatItem(Icons.square_foot_rounded, '${_n(b.superficie)} m²', 'surface'),
                StatItem(Icons.sell_outlined, CurrencyFormatter.fcfa(b.prix), 'prix de vente', highlight: true),
                if (prixM2 != null) StatItem(Icons.calculate_outlined, CurrencyFormatter.fcfa(prixM2), 'prix au m²'),
              ],
            ),
            DetailSection(
              title: 'Caractéristiques de la parcelle',
              child: InfoRows(
                rows: [
                  ('Surface', '${_n(b.superficie)} m²'),
                  if (b.facade != null) ('Façade', '${_n(b.facade!)} m'),
                  if (b.profondeur != null) ('Profondeur', '${_n(b.profondeur!)} m'),
                  if ((b.numeroTitreFoncier ?? '').isNotEmpty) ('Titre foncier', b.numeroTitreFoncier!),
                  ('Statut', libelleFamille(fam)),
                ],
              ),
            ),
            DetailSection(
              title: 'Équipements',
              child: Column(
                children: [
                  FeatureRow(
                    tiles: [
                      FeatureTile(
                        icon: Icons.water_drop_outlined,
                        title: 'Eau potable',
                        subtitle: b.eauSomapep == true ? 'Raccordé' : 'Non raccordé',
                        ok: b.eauSomapep == true,
                      ),
                      FeatureTile(
                        icon: Icons.bolt_outlined,
                        title: 'Réseau EDM',
                        subtitle: b.electriciteEdm == true ? 'Disponible' : 'Non raccordé',
                        ok: b.electriciteEdm == true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FeatureRow(
                    tiles: [
                      FeatureTile(
                        icon: Icons.alt_route_rounded,
                        title: 'Voirie',
                        subtitle: b.voieBitumee == true ? 'Bitumée' : 'Non bitumée',
                        ok: b.voieBitumee == true,
                      ),
                      FeatureTile(
                        icon: Icons.fence_rounded,
                        title: 'Clôture',
                        subtitle: b.murCloture == true ? 'Mur de clôture' : 'Sans clôture',
                        ok: b.murCloture == true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (maReservation != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.ambreReservation24h.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.ambreReservation24h.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: AppColors.ambreReservation24h),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Votre réservation (dossier ${maReservation.numeroDossier}) est en attente de la société. Vous pouvez l\'annuler à tout moment.',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF9A5B00), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            ReservationRuleBanner(reservationMultiple: b.reservationMultiple, isReserve: b.isReserve),
            if (!b.peutEtreReserve) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(14)),
                child: const Text('Cette parcelle n\'est pas réservable pour le moment.',
                    style: TextStyle(color: AppColors.grey600)),
              ),
            ],
          ],
        );
      },
    );
  }
}
