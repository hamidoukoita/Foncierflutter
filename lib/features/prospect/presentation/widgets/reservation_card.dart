import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/business_rules.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationCard({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnAttente = reservation.statut == 'EN_ATTENTE';
    final durationRestante =
        BusinessRules.tempsRestantReservation(reservation.dateReservation);
    final bool isExpired = durationRestante.inSeconds <= 0 && isEnAttente;

    Color borderColor = AppColors.borderLight;
    if (isEnAttente && !isExpired) {
      borderColor = AppColors.ambreReservation24h;
    } else if (isExpired || reservation.statut == 'REFUSER') {
      borderColor = AppColors.errorRed;
    } else if (reservation.statut == 'CONFIRMER') {
      borderColor = AppColors.successGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
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
                'Dossier N° ${reservation.numeroDossier}',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              _buildBadge(isEnAttente, isExpired),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Text(
            reservation.bienDesignation ?? 'Bien non renseigné',
            style: AppTextStyles.h4,
          ),
          if (reservation.programmeNom != null)
            Text(
              reservation.programmeNom!,
              style: AppTextStyles.bodyMedium,
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Montant : ${reservation.montant?.toStringAsFixed(0) ?? 'N/A'} FCFA',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
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
      text = 'EN ATTENTE 24H';
    } else if (reservation.statut == 'CONFIRMER') {
      color = AppColors.successGreen;
      text = 'CONFIRMÉE';
    } else {
      color = AppColors.errorRed;
      text = 'REFUSÉE';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall
            .copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
