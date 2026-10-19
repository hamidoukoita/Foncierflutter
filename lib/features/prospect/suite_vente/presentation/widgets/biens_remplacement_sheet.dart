import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_remplacement_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/annonce_artwork.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/confirm_dialog.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../providers/suite_vente_providers.dart';
import '../controllers/suite_vente_actions.dart';

/// Biens disponibles de la même société : l'acquéreur en choisit un pour y reporter sa réservation.
class BiensRemplacementSheet extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const BiensRemplacementSheet({super.key, required this.reservation});

  static Future<void> afficher(BuildContext context, ReservationModel reservation) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundOffWhite,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => BiensRemplacementSheet(reservation: reservation),
    );
  }

  @override
  ConsumerState<BiensRemplacementSheet> createState() => _BiensRemplacementSheetState();
}

class _BiensRemplacementSheetState extends ConsumerState<BiensRemplacementSheet> {
  int? _bienEnCours;

  Future<void> _choisir(BienRemplacementModel bien) async {
    final r = widget.reservation;
    final ok = await ConfirmDialog.show(
      context,
      icon: Icons.swap_horiz_rounded,
      title: 'Reporter sur ce bien ?',
      message: '${bien.libelleType} ${bien.designation} sera réservé avec les '
          '${CurrencyFormatter.fcfa(r.montantReservation)} déjà payés. Un agent prendra ensuite votre dossier en charge.',
      confirmLabel: 'Reporter ma réservation',
    );
    if (!ok || !mounted) return;
    setState(() => _bienEnCours = bien.id);
    final reporte = await SuiteVenteActions.remplacer(context, ref, r, bien);
    if (!mounted) return;
    setState(() => _bienEnCours = null);
    if (reporte) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final biens = ref.watch(biensRemplacementProvider(r.id));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, controleur) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: AppRadius.radiusRound),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choisir un autre bien', style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Vos ${CurrencyFormatter.fcfa(r.montantReservation)} servent de réservation, sans nouveau paiement.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: biens.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
              error: (e, _) => EmptyStateView(
                icon: Icons.cloud_off_rounded,
                title: 'Chargement impossible',
                message: ErrorHandler.messageOf(e),
                onRetry: () => ref.invalidate(biensRemplacementProvider(r.id)),
              ),
              data: (liste) => liste.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'Aucun bien disponible',
                      message: 'Cette société n’a pas d’autre bien à réserver pour le moment. '
                          'Vous pouvez demander le remboursement.',
                    )
                  : ListView.separated(
                      controller: controleur,
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.xl),
                      itemCount: liste.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
                      itemBuilder: (_, i) => _BienRemplacementTuile(
                        bien: liste[i],
                        chargement: _bienEnCours == liste[i].id,
                        onTap: _bienEnCours == null ? () => _choisir(liste[i]) : null,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BienRemplacementTuile extends StatelessWidget {
  final BienRemplacementModel bien;
  final bool chargement;
  final VoidCallback? onTap;

  const _BienRemplacementTuile({required this.bien, required this.chargement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final details = [
      bien.libelleType,
      if (bien.superficie != null) '${bien.superficie!.round()} m²',
      if ((bien.programmeNom ?? '').isNotEmpty) bien.programmeNom!,
    ].join(' · ');

    return Material(
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: BorderSide(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
          child: Row(
            children: [
              AnnonceArtwork(
                imageUrl: bien.imageUrl,
                estProgramme: bien.typeBien == 'LOT_PROGRAMME',
                largeur: 72,
                hauteur: 72,
                rayon: AppRadius.radiusMd,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bien.designation, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(details, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      CurrencyFormatter.fcfa(bien.prix),
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 15, color: AppColors.primaryOcreDark),
                    ),
                  ],
                ),
              ),
              chargement
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primaryOcre),
                    )
                  : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
