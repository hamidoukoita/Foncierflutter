import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';

/// Carte d'un rendez-vous de visite de l'acquéreur.
class RdvCard extends StatelessWidget {
  final RendezVousModel rdv;

  const RdvCard({super.key, required this.rdv});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String badge;
    if (rdv.isAccepte) {
      color = AppColors.successGreen;
      badge = 'CONFIRMÉ';
    } else if (rdv.isRefuse) {
      color = AppColors.errorRed;
      badge = 'REFUSÉ';
    } else {
      color = AppColors.ambreReservation24h;
      badge = 'EN ATTENTE';
    }

    final titre = rdv.bienDesignation ?? rdv.bienReference ?? 'Visite';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(titre, style: AppTextStyles.h4)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (rdv.programmeNom != null) ...[
            const SizedBox(height: 2),
            Text(rdv.programmeNom!, style: AppTextStyles.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.sm),
          _row(Icons.event_rounded, DateFormatter.dateLongue(rdv.dateRendezVous)),
          const SizedBox(height: 4),
          _row(
            Icons.schedule_rounded,
            rdv.creneauHeure?.isNotEmpty == true ? rdv.creneauHeure! : DateFormatter.heure(rdv.dateRendezVous),
          ),
          const SizedBox(height: 4),
          _row(
            rdv.isChantier ? Icons.landscape_rounded : Icons.business_rounded,
            rdv.isChantier ? 'Visite sur le terrain' : 'Rendez-vous au siège',
          ),
          if (rdv.lieu != null && rdv.lieu!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _row(Icons.place_outlined, rdv.lieu!),
          ],
          if (rdv.agentNom != null && rdv.agentNom!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            _row(Icons.person_outline_rounded, 'Avec ${rdv.agentNom}'),
          ],
          if (rdv.isRefuse && rdv.motifRefus != null && rdv.motifRefus!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Motif : ${rdv.motifRefus}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.errorRed, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}
