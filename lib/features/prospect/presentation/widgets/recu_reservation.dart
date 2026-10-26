import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';

/// Reçu d'une réservation : affiché juste après le paiement (ou la confirmation d'une
/// réservation gratuite), puis consultable à tout moment depuis « Réservations ».
/// Tout vient du serveur : le reçu est le même à chaque ouverture.
class RecuReservation extends StatelessWidget {
  final ReservationModel reservation;
  final String libelle;

  /// Juste après le paiement : coche verte et message de confirmation au-dessus du reçu.
  final bool enTete;
  final VoidCallback onTerminer;

  const RecuReservation({
    super.key,
    required this.reservation,
    required this.libelle,
    required this.onTerminer,
    this.enTete = false,
  });

  /// Rouvre le reçu d'une réservation existante dans une feuille du bas.
  static Future<void> afficher(BuildContext context, ReservationModel reservation) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
          child: RecuReservation(
            reservation: reservation,
            libelle: reservation.bienDesignation ?? 'Bien réservé',
            onTerminer: () => Navigator.of(sheetContext).pop(),
          ),
        ),
      ),
    );
  }

  List<(String, String)> get _lignes {
    final r = reservation;
    final date = r.datePaiement ?? r.dateReservation;
    return [
      ('Bien', libelle),
      if ((r.programmeNom ?? '').isNotEmpty) ('Cité', r.programmeNom!),
      ('Dossier', r.numeroDossier),
      if (r.estPayante) ...[
        ('Montant payé', CurrencyFormatter.fcfa(r.montantReservation)),
        ('Moyen', 'Orange Money'),
        ('Référence', r.referencePaiement ?? '—'),
      ],
      ('Date', '${DateFormatter.date(date)} à ${DateFormatter.heure(date)}'),
      if (r.estPayante) ('Si vous annulez', _regleAnnulation(r.pourcentageRemboursement)),
      if (r.rembourse && r.montantRembourse != null) ('Remboursé', CurrencyFormatter.fcfa(r.montantRembourse)),
    ];
  }

  static String _regleAnnulation(int pourcentage) {
    if (pourcentage <= 0) return 'Non remboursé';
    if (pourcentage >= 100) return 'Remboursé en totalité';
    return '$pourcentage % remboursé';
  }

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (enTete) ...[
          const Center(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.successGreenSoft,
              child: Icon(Icons.check_rounded, size: 34, color: AppColors.successGreen),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            r.estPayante ? 'Paiement accepté' : 'Réservation enregistrée',
            textAlign: TextAlign.center,
            style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Un agent va prendre votre dossier en charge. Retrouvez ce reçu dans « Réservations ».',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ] else
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.primaryOcre),
              const SizedBox(width: AppSpacing.sm),
              Text(
                r.estPayante ? 'Reçu de paiement' : 'Reçu de réservation',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.backgroundOffWhite,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              for (final (libelleLigne, valeur) in _lignes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(libelleLigne, style: AppTextStyles.bodySmall),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          valeur,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DetailButton(
          label: enTete ? 'Terminé' : 'Fermer',
          icon: Icons.check_rounded,
          onPressed: onTerminer,
        ),
      ],
    );
  }
}
