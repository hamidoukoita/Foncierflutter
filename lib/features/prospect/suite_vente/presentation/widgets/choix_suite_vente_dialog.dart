import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import '../controllers/suite_vente_actions.dart';
import 'biens_remplacement_sheet.dart';

enum _Choix { autreBien, rembourse }

/// Popup affiché quand le bien réservé a été vendu à un autre acquéreur :
/// reporter le montant payé sur un autre bien de la société, ou être remboursé sous 24 h.
class ChoixSuiteVenteDialog extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const ChoixSuiteVenteDialog({super.key, required this.reservation});

  /// Ouvre le popup puis, si l'acquéreur choisit un autre bien, la liste des biens proposés.
  static Future<void> afficher(BuildContext context, ReservationModel reservation) async {
    final choix = await showDialog<_Choix>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => ChoixSuiteVenteDialog(reservation: reservation),
    );
    if (choix == _Choix.autreBien && context.mounted) {
      await BiensRemplacementSheet.afficher(context, reservation);
    }
  }

  @override
  ConsumerState<ChoixSuiteVenteDialog> createState() => _ChoixSuiteVenteDialogState();
}

class _ChoixSuiteVenteDialogState extends ConsumerState<ChoixSuiteVenteDialog> {
  bool _enCours = false;

  Future<void> _rembourser() async {
    setState(() => _enCours = true);
    final ok = await SuiteVenteActions.rembourser(context, ref, widget.reservation);
    if (!mounted) return;
    setState(() => _enCours = false);
    if (ok) Navigator.of(context).pop(_Choix.rembourse);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final montant = CurrencyFormatter.fcfa(r.montantReservation);
    final limite = r.dateLimiteChoix;

    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.warningAmberSoft,
                child: Icon(Icons.campaign_rounded, size: 30, color: AppColors.ambreReservation24h),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Ce bien a été vendu',
                textAlign: TextAlign.center, style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '« ${r.bienDesignation ?? 'Le bien'} » a été vendu à un autre acquéreur. '
              'Vous aviez payé $montant pour le réserver : que souhaitez-vous en faire ?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _OptionChoix(
              icone: Icons.home_work_rounded,
              couleur: AppColors.primaryOcreDark,
              fond: AppColors.primaryOcreSoft,
              titre: 'Réserver un autre bien',
              detail: 'Choisissez un bien de la même société : vos $montant servent de réservation, sans repayer.',
              onTap: _enCours ? null : () => Navigator.of(context).pop(_Choix.autreBien),
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            _OptionChoix(
              icone: Icons.currency_exchange_rounded,
              couleur: AppColors.orangeMoney,
              fond: AppColors.orangeMoneySoft,
              titre: 'Être remboursé sous 24 h',
              detail: '$montant renvoyés sur votre compte Orange Money.',
              chargement: _enCours,
              onTap: _enCours ? null : _rembourser,
            ),
            if (limite != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sans choix de votre part, vous serez remboursé d’office le '
                '${DateFormatter.date(limite)} à ${DateFormatter.heure(limite)}.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: _enCours ? null : () => Navigator.of(context).pop(),
              child: const Text('Décider plus tard'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une des deux réponses possibles, présentée comme une carte à toucher.
class _OptionChoix extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String titre;
  final String detail;
  final bool chargement;
  final VoidCallback? onTap;

  const _OptionChoix({
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.titre,
    required this.detail,
    required this.onTap,
    this.chargement = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: BorderSide(color: couleur.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: fond, borderRadius: AppRadius.radiusMd),
                child: chargement
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: couleur),
                      )
                    : Icon(icone, color: couleur),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: AppTextStyles.cardTitle),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(detail, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
