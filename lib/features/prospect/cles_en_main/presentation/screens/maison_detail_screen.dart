import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/localisation_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/presentation/controllers/localisation_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/presentation/widgets/commodites_carousel.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/presentation/widgets/localisation_preview_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/info_banner.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_booking_sheet.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_rule_banner.dart';
import '../../domain/maison_cle_en_main.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/construction_routes.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import '../../providers/maisons_providers.dart';

/// Fiche d'une maison clé en main : même gabarit que la cité, le lot et la parcelle.
class MaisonDetailScreen extends ConsumerStatefulWidget {
  final int maisonId;
  const MaisonDetailScreen({super.key, required this.maisonId});

  @override
  ConsumerState<MaisonDetailScreen> createState() => _MaisonDetailScreenState();
}

class _MaisonDetailScreenState extends ConsumerState<MaisonDetailScreen> {
  bool _reservation = false;
  bool _annulation = false;

  Future<void> _reserver(MaisonCleEnMain m) async {
    setState(() => _reservation = true);
    await reserverBienAvecConfirmation(context, ref, bienId: m.id, libelle: m.titre);
    ref.invalidate(maisonDetailProvider(widget.maisonId));
    if (mounted) setState(() => _reservation = false);
  }

  Future<void> _annuler(ReservationModel r) async {
    setState(() => _annulation = true);
    final ok = await annulerReservationAvecConfirmation(context, ref, r);
    if (ok) ref.invalidate(maisonDetailProvider(widget.maisonId));
    if (mounted) setState(() => _annulation = false);
  }

  Future<void> _rafraichir() async {
    ref.invalidate(maisonDetailProvider(widget.maisonId));
    ref.invalidate(mediasBienProvider(widget.maisonId));
    ref.invalidate(localisationBienProvider(widget.maisonId));
  }

  static String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(maisonDetailProvider(widget.maisonId));
    final medias = ref.watch(mediasBienProvider(widget.maisonId));
    final lieu = ref.watch(localisationBienProvider(widget.maisonId)).valueOrNull;

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
          title: 'Maison introuvable',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(maisonDetailProvider(widget.maisonId)),
        ),
      ),
      data: (m) {
        final famille = familleDeStatut(m.statut);
        final maReservation = maReservationEnAttente(ref.watch(mesReservationsProvider).valueOrNull, m.id);

        return DetailPage(
          title: m.titre,
          medias: medias.valueOrNull ?? const [],
          mediasLoading: medias.isLoading,
          onBack: () => context.pop(),
          onRefresh: _rafraichir,
          bottomBar: DetailActionBar(
            actions: [
              if (maReservation != null)
                DetailButton(
                  label: 'Annuler ma réservation',
                  icon: Icons.close_rounded,
                  danger: true,
                  loading: _annulation,
                  onPressed: () => _annuler(maReservation),
                )
              else if (m.peutEtreReserve)
                DetailButton(
                  label: 'Réserver',
                  icon: Icons.bookmark_add_outlined,
                  loading: _reservation,
                  onPressed: () => _reserver(m),
                ),
              DetailButton(
                label: 'Visiter',
                icon: Icons.event_available_outlined,
                color: AppColors.primaryBlueAnthracite,
                onPressed: () => RdvBookingSheet.show(
                  context,
                  bienId: m.id,
                  societeId: m.societeId,
                  bienLabel: m.titre,
                  societeNom: m.societeNom,
                  chantierLabel: m.adresse,
                ),
              ),
            ],
          ),
          children: [
            DetailHeader(
              title: m.titre,
              statusLabel: libelleFamille(famille),
              statusColor: couleurFamille(famille),
              subtitle: m.societeNom,
              subtitleIcon: Icons.business_rounded,
              tags: [
                'Clé en main',
                if (m.niveaux != null) m.niveaux!,
                if ((m.numeroTitreFoncier ?? '').isNotEmpty) 'TF : ${m.numeroTitreFoncier}',
              ],
            ),
            StatStrip(
              items: [
                StatItem(Icons.sell_outlined, CurrencyFormatter.fcfa(m.prix), 'prix de vente', highlight: true),
                if (m.nombreChambres != null) StatItem(Icons.bed_outlined, '${m.nombreChambres}', 'chambres'),
                if (m.surfaceHabitable != null)
                  StatItem(Icons.home_outlined, '${_n(m.surfaceHabitable!)} m²', 'habitables'),
              ],
            ),
            if ((m.description ?? '').isNotEmpty)
              DetailSection(
                title: 'La maison',
                child: Text(m.description!, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
              ),
            DetailSection(
              title: 'Caractéristiques',
              child: InfoRows(
                rows: [
                  if (m.nombreChambres != null) ('Chambres', '${m.nombreChambres}'),
                  if (m.nombreSallesBain != null) ('Salles de bain', '${m.nombreSallesBain}'),
                  if (m.niveaux != null) ('Niveaux', m.niveaux!),
                  if (m.surfaceHabitable != null) ('Surface habitable', '${_n(m.surfaceHabitable!)} m²'),
                  ('Terrain', '${_n(m.superficie)} m²'),
                  if ((m.numeroTitreFoncier ?? '').isNotEmpty) ('Titre foncier', m.numeroTitreFoncier!),
                  ('Disponibilité', libelleFamille(famille)),
                ],
              ),
            ),
            if (m.equipements.isNotEmpty)
              DetailSection(
                title: 'Équipements',
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final eq in m.equipements)
                      Chip(
                        avatar: const Icon(Icons.check_rounded, size: 16, color: AppColors.successGreen),
                        label: Text(eq),
                        backgroundColor: AppColors.successGreenSoft,
                        side: BorderSide.none,
                        labelStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.successGreen, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              ),
            if (lieu != null) ...[
              DetailSection(
                title: 'Localisation',
                child: LocalisationPreviewCard(
                  lieu: lieu,
                  onOuvrir: () => context.push(LocalisationRoutes.bien(m.id)),
                ),
              ),
              if (lieu.commodites.isNotEmpty)
                DetailSection(
                  title: 'Commodités autour',
                  child: CommoditesCarousel(commodites: lieu.commodites),
                ),
            ],
            // Vous avez déjà un terrain : faire construire la même maison par cette société.
            if (m.societeId != null)
              DetailSection(
                title: 'Vous avez déjà un terrain ?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${m.societeNom ?? 'Le promoteur'} peut construire une maison comme celle-ci sur votre parcelle titrée.',
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: AppSpacing.md - AppSpacing.xs),
                    AppActionButton(
                      label: 'Construire une maison comme celle-ci',
                      icon: Icons.home_work_outlined,
                      variant: AppActionVariant.dark,
                      onPressed: () => context.push(ConstructionRoutes.nouveau, extra: m),
                    ),
                  ],
                ),
              ),
            if (maReservation != null) ...[
              const SizedBox(height: AppSpacing.md),
              InfoBanner.reservationEnAttente(numeroDossier: maReservation.numeroDossier),
            ],
            const SizedBox(height: AppSpacing.md),
            ReservationRuleBanner(reservationMultiple: m.reservationMultiple, isReserve: m.isReserve),
            if (!m.peutEtreReserve) ...[
              const SizedBox(height: AppSpacing.md - AppSpacing.xs),
              const InfoBanner(
                icone: Icons.block_rounded,
                message: 'Cette maison n\'est pas réservable pour le moment.',
              ),
            ],
          ],
        );
      },
    );
  }
}
