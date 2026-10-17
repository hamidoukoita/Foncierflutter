import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_routes.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/reservations/presentation/controllers/reservation_agent_actions.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_placeholder.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_statut_style.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import '../domain/reservation_suivi.dart';

/// Carte d'une réservation suivie par l'agent : bien, acquéreur, paiement, décompte
/// et action de l'étape (démarrer le décompte, puis conclure la vente).
class ReservationSuiviCard extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const ReservationSuiviCard({super.key, required this.reservation});

  @override
  ConsumerState<ReservationSuiviCard> createState() => _ReservationSuiviCardState();
}

class _ReservationSuiviCardState extends ConsumerState<ReservationSuiviCard> {
  bool _enCours = false;

  Future<void> _agir(Future<void> Function(BuildContext, WidgetRef, ReservationModel) action) async {
    setState(() => _enCours = true);
    await action(context, ref, widget.reservation);
    if (mounted) setState(() => _enCours = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final style = ReservationStatutStyle.de(r);
    final progression = r.isEnCours ? r.progression() : null;

    return AppCard(
      onTap: () => context.push(AgentRoutes.reservationDetail(r.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const ImagePlaceholder(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.titreSuivi.isEmpty ? 'Dossier ${r.numeroDossier}' : r.titreSuivi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Acquéreur : ${r.acquereurNom ?? '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Flexible(
                          child: SoftBadge(
                            label: style.libelle,
                            background: style.fond,
                            foreground: style.couleur,
                            icon: style.icone,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Spacer(),
                        Text(
                          r.estPayante ? CurrencyFormatter.fcfaCompact(r.montantReservation) : 'Gratuite',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryOcre,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progression != null) ...[
            const SizedBox(height: AppSpacing.md - AppSpacing.xs),
            ClipRRect(
              borderRadius: AppRadius.radiusRound,
              child: LinearProgressIndicator(
                value: 1 - progression,
                minHeight: 6,
                color: style.couleur,
                backgroundColor: AppColors.grey100,
              ),
            ),
          ],
          if (r.aDemarrer) ...[
            const SizedBox(height: AppSpacing.md - AppSpacing.xs),
            DetailButton(
              label: 'Démarrer le décompte',
              icon: Icons.timer_outlined,
              compact: true,
              loading: _enCours,
              onPressed: () => _agir(ReservationAgentActions.demarrer),
            ),
          ] else if (r.peutConclure()) ...[
            const SizedBox(height: AppSpacing.md - AppSpacing.xs),
            DetailButton(
              label: 'Marquer vendu',
              icon: Icons.sell_outlined,
              compact: true,
              color: AppColors.successGreen,
              loading: _enCours,
              onPressed: () => _agir(ReservationAgentActions.vendre),
            ),
          ],
        ],
      ),
    );
  }
}
