import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/icon_label.dart';

/// Carte d'un rendez-vous de visite de l'acquéreur, avec annulation tant qu'il n'est pas passé.
class RdvCard extends ConsumerStatefulWidget {
  final RendezVousModel rdv;

  const RdvCard({super.key, required this.rdv});

  @override
  ConsumerState<RdvCard> createState() => _RdvCardState();
}

class _RdvCardState extends ConsumerState<RdvCard> {
  bool _busy = false;

  Future<void> _annuler() async {
    setState(() => _busy = true);
    await annulerRendezVousAvecConfirmation(context, ref, widget.rdv.id);
    if (mounted) setState(() => _busy = false);
  }

  (String, Color) get _statut {
    final rdv = widget.rdv;
    if (rdv.isAnnule) return ('Annulé', AppColors.grey600);
    if (rdv.isAccepte) return ('Confirmé', AppColors.successGreen);
    if (rdv.isRefuse) return ('Refusé', AppColors.errorRed);
    return ('En attente', AppColors.ambreReservation24h);
  }

  @override
  Widget build(BuildContext context) {
    final rdv = widget.rdv;
    final (libelle, couleur) = _statut;
    final peutAnnuler =
        !rdv.isRefuse && rdv.dateRendezVous.isAfter(DateTime.now());
    final lieu = (rdv.lieu != null && rdv.lieu!.isNotEmpty)
        ? rdv.lieu!
        : (rdv.isChantier ? 'Visite sur le terrain' : 'Rendez-vous au siège');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BlocDate(date: rdv.debut),
              const SizedBox(width: AppSpacing.md - AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusPill(label: libelle, color: couleur),
                    const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                    Text(
                      rdv.bienDesignation ?? rdv.bienReference ?? 'Visite',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    if ((rdv.programmeNom ?? '').isNotEmpty)
                      Text(rdv.programmeNom!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md - AppSpacing.xxs),
          const Divider(),
          const SizedBox(height: AppSpacing.md - AppSpacing.xs),
          IconLabel(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.primaryOcre,
            text:
                '${DateFormatter.dateLongue(rdv.debut)} · ${DateFormatter.plageHoraire(rdv.debut, rdv.fin)}',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: AppSpacing.sm),
          IconLabel(
            icon: rdv.isChantier
                ? Icons.landscape_rounded
                : Icons.business_rounded,
            iconColor: AppColors.primaryOcre,
            text: lieu,
            style: AppTextStyles.label,
          ),
          if (rdv.agentNom != null && rdv.agentNom!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            IconLabel(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primaryOcre,
              text: 'Avec ${rdv.agentNom}',
              style: AppTextStyles.label,
            ),
          ],
          if (rdv.isRefuse &&
              !rdv.isAnnule &&
              (rdv.motifRefus ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md - AppSpacing.xs),
            Text(
              'Motif : ${rdv.motifRefus}',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.errorRed, fontWeight: FontWeight.w600),
            ),
          ],
          if (peutAnnuler) ...[
            const SizedBox(height: AppSpacing.md),
            DetailButton(
              label: 'Annuler le rendez-vous',
              icon: Icons.close_rounded,
              danger: true,
              compact: true,
              loading: _busy,
              onPressed: _annuler,
            ),
          ],
        ],
      ),
    );
  }
}

/// Pavé calendrier : jour en grand, mois abrégé.
class _BlocDate extends StatelessWidget {
  final DateTime date;
  const _BlocDate({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
          gradient: AppGradients.navy, borderRadius: AppRadius.radiusLg),
      child: Column(
        children: [
          Text(DateFormatter.jourCourt(date),
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.primaryOcreLight)),
          Text('${date.day}',
              style: AppTextStyles.h2
                  .copyWith(color: AppColors.white, height: 1.1)),
          Text(DateFormatter.moisCourt(date),
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.onDarkMuted)),
        ],
      ),
    );
  }
}
