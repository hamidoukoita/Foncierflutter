import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/map_constants.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/bien_libelle.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/reservation_suivi.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/agent_async_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/back_title_header.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/map/foncier_osm_viewer.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_statut_style.dart';
import '../controllers/reservation_agent_actions.dart';

/// Dossier de réservation suivi par l'agent : contexte, client, bien, localisation et itinéraire,
/// avec l'action de l'étape (démarrer le décompte, puis conclure la vente).
class ReservationDetailScreen extends ConsumerWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservation = ref.watch(agentReservationProvider(reservationId));

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md + AppSpacing.xs, AppSpacing.md + AppSpacing.xs, AppSpacing.md + AppSpacing.xs, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BackTitleHeader(title: 'Dossier de réservation'),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AgentAsyncView<ReservationModel?>(
                  value: reservation,
                  onRetry: () => ref.invalidate(agentReservationsProvider),
                  builder: (r) => r == null
                      ? const EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'Dossier introuvable',
                          message: 'Cette réservation ne vous est plus attribuée.',
                        )
                      : _Contenu(reservation: r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contenu extends ConsumerStatefulWidget {
  final ReservationModel reservation;
  const _Contenu({required this.reservation});

  @override
  ConsumerState<_Contenu> createState() => _ContenuState();
}

class _ContenuState extends ConsumerState<_Contenu> {
  bool _enCours = false;

  Future<void> _agir(Future<void> Function(BuildContext, WidgetRef, ReservationModel) action) async {
    setState(() => _enCours = true);
    await action(context, ref, widget.reservation);
    if (mounted) setState(() => _enCours = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final bienId = r.bienId;
    final bien = bienId == null ? null : ref.watch(bienFoncierProvider(bienId)).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryOcre,
            onRefresh: () async {
              ref.invalidate(agentReservationsProvider);
              if (bienId != null) ref.invalidate(bienFoncierProvider(bienId));
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                _EnTete(reservation: r),
                const SizedBox(height: AppSpacing.md),
                _Contexte(reservation: r),
                DetailSection(
                  title: 'Client',
                  child: _Client(reservation: r),
                ),
                if (bien != null)
                  DetailSection(
                    title: 'Le bien',
                    child: InfoRows(rows: _lignesBien(bien)),
                  ),
                if (bienId != null)
                  DetailSection(
                    title: 'Localisation',
                    child: _Localisation(bienId: bienId, adresse: bien?.localisation),
                  ),
              ],
            ),
          ),
        ),
        if (r.aDemarrer || r.peutConclure())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: r.aDemarrer
                ? DetailButton(
                    label: 'Démarrer le décompte',
                    icon: Icons.timer_outlined,
                    loading: _enCours,
                    onPressed: () => _agir(ReservationAgentActions.demarrer),
                  )
                : DetailButton(
                    label: 'Marquer vendu',
                    icon: Icons.sell_outlined,
                    color: AppColors.successGreen,
                    loading: _enCours,
                    onPressed: () => _agir(ReservationAgentActions.vendre),
                  ),
          ),
      ],
    );
  }

  static String _n(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);

  /// Informations de base pour situer le bien (sans médias).
  static List<(String, String)> _lignesBien(BienFoncierModel b) {
    final viabilisation = BienLibelle.joindre([
      if (b.eauSomapep == true) 'Eau',
      if (b.electriciteEdm == true) 'Électricité',
      if (b.voieBitumee == true) 'Voie bitumée',
      if (b.murCloture == true) 'Clôture',
    ]);
    return [
      ('Type', b.isMaison ? 'Maison clé en main' : b.isLot ? 'Lot de cité' : 'Parcelle individuelle'),
      ('Désignation', b.designation),
      if ((b.programmeNom ?? '').isNotEmpty) ('Cité', b.programmeNom!),
      if (b.reference.isNotEmpty) ('Référence', b.reference),
      ('Surface', '${_n(b.superficie)} m²'),
      ('Prix de vente', CurrencyFormatter.fcfa(b.prix)),
      if ((b.numeroTitreFoncier ?? '').isNotEmpty) ('Titre foncier', b.numeroTitreFoncier!),
      if ((b.localisation ?? '').isNotEmpty) ('Adresse', b.localisation!),
      if (viabilisation.isNotEmpty) ('Viabilisation', viabilisation),
    ];
  }
}

class _EnTete extends StatelessWidget {
  final ReservationModel reservation;
  const _EnTete({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final style = ReservationStatutStyle.de(r);
    final progression = r.isEnCours ? r.progression() : null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('DOSSIER ${r.numeroDossier}', style: AppTextStyles.overline)),
              StatusPill(label: style.libelle, color: style.couleur),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(r.titreSuivi.isEmpty ? 'Bien réservé' : r.titreSuivi, style: AppTextStyles.h4),
          if (progression != null && r.dateExpiration != null) ...[
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            ClipRRect(
              borderRadius: AppRadius.radiusRound,
              child: LinearProgressIndicator(
                value: 1 - progression,
                minHeight: 6,
                color: style.couleur,
                backgroundColor: AppColors.grey100,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Échéance le ${DateFormatter.date(r.dateExpiration!)} à ${DateFormatter.heure(r.dateExpiration!)}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Le contexte du dossier en une phrase : ce qui a été payé et ce qu'on attend de l'agent.
class _Contexte extends StatelessWidget {
  final ReservationModel reservation;
  const _Contexte({required this.reservation});

  String get _texte {
    final r = reservation;
    final duree = r.dureeReservationHeures == null
        ? 'la durée fixée par la société'
        : DateFormatter.dureeLisible(Duration(hours: r.dureeReservationHeures!));
    final paiement = r.estPayante
        ? '${r.acquereurNom ?? 'L’acquéreur'} a payé ${CurrencyFormatter.fcfa(r.montantReservation)} le '
            '${DateFormatter.date(r.datePaiement ?? r.dateReservation)}'
            '${r.referencePaiement == null ? '' : ' (réf. ${r.referencePaiement})'} pour réserver ce bien.'
        : '${r.acquereurNom ?? 'L’acquéreur'} a réservé ce bien le ${DateFormatter.date(r.dateReservation)}.';
    switch (r.etape) {
      case StatutReservation.enAttente:
        return '$paiement Contactez-le, puis démarrez le décompte : le bien lui sera réservé $duree pour conclure la vente.';
      case StatutReservation.enCours:
        return '$paiement Le décompte est lancé : concluez la vente avant l’échéance, sinon la réservation expire.';
      case StatutReservation.vendue:
        return 'Vente conclue. Merci pour le suivi de ce dossier.';
      case StatutReservation.expiree:
        return 'Le délai est écoulé sans vente : le bien est de nouveau disponible.';
      case StatutReservation.annulee:
        return reservation.motifAnnulation ?? 'Réservation annulée.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: const BoxDecoration(color: AppColors.primaryOcreSoft, borderRadius: AppRadius.radiusLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryOcreDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(_texte,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlueAnthracite, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _Client extends StatelessWidget {
  final ReservationModel reservation;
  const _Client({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final telephone = reservation.acquereurTelephone;
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryBlueAnthracite,
          child: Icon(Icons.person_rounded, color: AppColors.white),
        ),
        const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reservation.acquereurNom ?? 'Acquéreur', style: AppTextStyles.cardTitle),
              if (telephone != null)
                Text(Telephone.afficher(telephone, avecIndicatif: true), style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        if (telephone != null)
          IconButton.filledTonal(
            tooltip: 'Appeler',
            onPressed: () => AgentActions.appeler(context, telephone),
            icon: const Icon(Icons.call_rounded, color: AppColors.successGreen),
          ),
      ],
    );
  }
}

/// Carte du lieu et bouton d'itinéraire Google Maps.
class _Localisation extends ConsumerWidget {
  static const double _hauteurCarte = 180;

  final int bienId;
  final String? adresse;
  const _Localisation({required this.bienId, this.adresse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionBienProvider(bienId)).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadius.radiusLg,
          child: SizedBox(
            height: _hauteurCarte,
            child: position == null
                ? const ColoredBox(
                    color: AppColors.placeholderSurface,
                    child: Center(child: Icon(Icons.location_off_outlined, color: AppColors.grey500, size: 32)),
                  )
                : FoncierOsmViewer(centre: position, zoom: MapConstants.zoomCite, afficherAttribution: false),
          ),
        ),
        if ((adresse ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(adresse!, style: AppTextStyles.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
        DetailButton(
          label: 'Itinéraire',
          icon: Icons.directions_rounded,
          color: AppColors.primaryBlueAnthracite,
          compact: true,
          onPressed: () => AgentActions.itineraire(context, bienId: bienId, adresseSecours: adresse),
        ),
      ],
    );
  }
}
