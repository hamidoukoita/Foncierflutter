import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_placeholder.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import '../domain/reservation_suivi.dart';

/// Carte d'une réservation suivie par l'agent (bien, acquéreur, délai, prix).
class ReservationSuiviCard extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationSuiviCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final style = EtatSuiviStyle.de(reservation);
    final estConfirmee = reservation.etatSuivi() == EtatSuivi.confirmee;

    return AppCard(
      child: Row(
        children: [
          const ImagePlaceholder(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.titreSuivi.isEmpty
                      ? 'Dossier ${reservation.numeroDossier}'
                      : reservation.titreSuivi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'Acquéreur : ${reservation.acquereurNom ?? '—'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    SoftBadge(
                      label: style.libelle,
                      background: style.fond,
                      foreground: style.couleur,
                      icon: style.icone,
                    ),
                    const Spacer(),
                    if (reservation.montant != null)
                      Text(
                        CurrencyFormatter.fcfaCompact(reservation.montant!),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: estConfirmee
                              ? AppColors.primaryBlueAnthracite
                              : AppColors.primaryOcre,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
