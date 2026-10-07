import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/business_rules.dart';

class AgentReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback onConfirmer;
  final VoidCallback onAnnuler;

  const AgentReservationCard({
    super.key,
    required this.reservation,
    required this.onConfirmer,
    required this.onAnnuler,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnAttente = reservation.statut == 'EN_ATTENTE';
    final durationRestante =
        BusinessRules.tempsRestantReservation(reservation.dateReservation);
    final bool isExpired = durationRestante.inSeconds <= 0 && isEnAttente;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dossier ${reservation.numeroDossier}',
                style: AppTextStyles.h4,
              ),
              _buildBadge(isEnAttente, isExpired),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Text('Client : ${reservation.acquereurNom ?? "N/A"}',
              style: AppTextStyles.bodyMedium),
          Text('Tél : ${reservation.acquereurTelephone ?? "N/A"}',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Bien : ${reservation.bienReference ?? "N/A"}',
              style: AppTextStyles.bodyMedium),
          if (isEnAttente && !isExpired)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.ambreReservation24h, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Expire dans : ${durationRestante.inHours}h ${durationRestante.inMinutes % 60}m',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.ambreReservation24h,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          if (isEnAttente)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                children: [
                  if (!isExpired)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirmer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Confirmer'),
                      ),
                    ),
                  if (!isExpired) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAnnuler,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                      ),
                      child: Text(isExpired ? 'Libérer le bien' : 'Annuler'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isEnAttente, bool isExpired) {
    Color color;
    String text;
    if (isExpired) {
      color = AppColors.errorRed;
      text = 'EXPIRÉE';
    } else if (isEnAttente) {
      color = AppColors.ambreReservation24h;
      text = '24H';
    } else if (reservation.statut == 'CONFIRMER') {
      color = AppColors.successGreen;
      text = 'CONFIRMÉE';
    } else {
      color = AppColors.grey500;
      text = reservation.statut;
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall
            .copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
