import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

enum InfoBannerTon { attention, neutre }

/// Encart d'information des fiches (réservation en attente, bien non réservable…).
class InfoBanner extends StatelessWidget {
  final IconData icone;
  final String message;
  final InfoBannerTon ton;

  const InfoBanner({
    super.key,
    required this.icone,
    required this.message,
    this.ton = InfoBannerTon.neutre,
  });

  /// Réservation de l'acquéreur encore en attente sur ce bien.
  const InfoBanner.reservationEnAttente(
      {super.key, required String numeroDossier})
      : icone = Icons.hourglass_top_rounded,
        ton = InfoBannerTon.attention,
        message =
            'Votre réservation (dossier $numeroDossier) est en attente de la société. '
                'Vous pouvez l\'annuler à tout moment.';

  @override
  Widget build(BuildContext context) {
    final attention = ton == InfoBannerTon.attention;
    final couleur = attention ? AppColors.primaryOcreDark : AppColors.grey700;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xxs),
      decoration: BoxDecoration(
        color: attention ? AppColors.warningAmberSoft : AppColors.grey100,
        borderRadius: AppRadius.radiusLg,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: AppColors.white, shape: BoxShape.circle),
            child: Icon(icone,
                size: 18,
                color: attention
                    ? AppColors.ambreReservation24h
                    : AppColors.grey600),
          ),
          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.label.copyWith(color: couleur, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
