import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';

/// Réservation d'un bien : récapitulatif des conditions, paiement Orange Money (simulé)
/// puis reçu. Si la société a fixé un prix de zéro, la réservation se confirme sans paiement.
class PaiementReservationSheet extends StatefulWidget {
  final String libelle;
  final ConditionsReservation conditions;
  final Future<ReservationModel> Function() reserver;

  const PaiementReservationSheet({
    super.key,
    required this.libelle,
    required this.conditions,
    required this.reserver,
  });

  /// Ouvre la feuille ; renvoie la réservation créée, ou null si l'acquéreur renonce.
  static Future<ReservationModel?> afficher(
    BuildContext context, {
    required String libelle,
    required ConditionsReservation conditions,
    required Future<ReservationModel> Function() reserver,
  }) {
    return showModalBottomSheet<ReservationModel>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => PaiementReservationSheet(libelle: libelle, conditions: conditions, reserver: reserver),
    );
  }

  @override
  State<PaiementReservationSheet> createState() => _PaiementReservationSheetState();
}

class _PaiementReservationSheetState extends State<PaiementReservationSheet> {
  /// Durée affichée du « traitement » Orange Money, pour un parcours crédible.
  static const Duration _attentePaiement = Duration(milliseconds: 1400);

  bool _enCours = false;
  String? _erreur;
  ReservationModel? _recu;

  Future<void> _payer() async {
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final resultats = await Future.wait<Object?>([
        widget.reserver(),
        if (widget.conditions.payante) Future<void>.delayed(_attentePaiement),
      ]);
      if (!mounted) return;
      setState(() => _recu = resultats.first as ReservationModel);
    } catch (e) {
      if (mounted) setState(() => _erreur = ErrorHandler.messageOf(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: AppRadius.radiusRound),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _recu != null
                  ? _Recu(key: const ValueKey('recu'), reservation: _recu!, libelle: widget.libelle)
                  : _Recapitulatif(
                      key: const ValueKey('recap'),
                      libelle: widget.libelle,
                      conditions: widget.conditions,
                      enCours: _enCours,
                      erreur: _erreur,
                      onPayer: _payer,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recapitulatif extends StatelessWidget {
  final String libelle;
  final ConditionsReservation conditions;
  final bool enCours;
  final String? erreur;
  final VoidCallback onPayer;

  const _Recapitulatif({
    super.key,
    required this.libelle,
    required this.conditions,
    required this.enCours,
    required this.erreur,
    required this.onPayer,
  });

  @override
  Widget build(BuildContext context) {
    final duree = DateFormatter.dureeLisible(Duration(hours: conditions.dureeHeures));
    final regles = [
      if (conditions.payante)
        (Icons.money_off_rounded, 'Montant non remboursable si vous annulez votre réservation.'),
      (Icons.support_agent_rounded, 'Un agent de ${conditions.societeNom ?? 'la société'} prend ensuite votre dossier en charge.'),
      (
        Icons.timer_outlined,
        'Dès qu’il démarre le suivi, le bien vous est réservé $duree pour conclure la vente. '
            '${conditions.payante ? 'Passé ce délai, la réservation expire et le montant n’est pas rendu.' : 'Passé ce délai, la réservation expire.'}',
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Réserver ce bien', style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
        const SizedBox(height: AppSpacing.xs),
        Text(libelle, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: conditions.payante ? AppColors.orangeMoneySoft : AppColors.successGreenSoft,
            borderRadius: AppRadius.radiusLg,
          ),
          child: Row(
            children: [
              Icon(
                conditions.payante ? Icons.smartphone_rounded : Icons.redeem_rounded,
                color: conditions.payante ? AppColors.orangeMoney : AppColors.successGreen,
              ),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
              Expanded(
                child: Text(
                  conditions.payante ? 'Montant de la réservation' : 'Réservation sans frais',
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (conditions.payante)
                Text(
                  CurrencyFormatter.fcfa(conditions.montant),
                  style: AppTextStyles.price.copyWith(fontSize: 20, color: AppColors.primaryBlueAnthracite),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (icone, texte) in regles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icone, size: 18, color: AppColors.primaryOcre),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(texte, style: AppTextStyles.bodySmall)),
              ],
            ),
          ),
        if (erreur != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AuthErrorBanner(message: erreur!),
        ],
        const SizedBox(height: AppSpacing.md),
        if (enCours && conditions.payante)
          const _PaiementEnCours()
        else
          DetailButton(
            label: conditions.payante ? 'Payer avec Orange Money' : 'Confirmer la réservation',
            icon: conditions.payante ? Icons.phone_iphone_rounded : Icons.bookmark_add_rounded,
            color: conditions.payante ? AppColors.orangeMoney : null,
            loading: enCours,
            onPressed: onPayer,
          ),
        if (conditions.payante) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Paiement simulé pour la démonstration : aucun montant n’est réellement débité.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _PaiementEnCours extends StatelessWidget {
  const _PaiementEnCours();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.orangeMoneySoft, borderRadius: AppRadius.radiusLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.orangeMoney),
          ),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
          Text('Paiement Orange Money en cours…',
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, color: AppColors.primaryBlueAnthracite)),
        ],
      ),
    );
  }
}

/// Reçu affiché après le paiement (ou la confirmation d'une réservation gratuite).
class _Recu extends StatelessWidget {
  final ReservationModel reservation;
  final String libelle;

  const _Recu({super.key, required this.reservation, required this.libelle});

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final lignes = [
      ('Bien', libelle),
      ('Dossier', r.numeroDossier),
      if (r.estPayante) ...[
        ('Montant payé', CurrencyFormatter.fcfa(r.montantReservation)),
        ('Moyen', 'Orange Money'),
        ('Référence', r.referencePaiement ?? '—'),
      ],
      ('Date', '${DateFormatter.date(r.datePaiement ?? r.dateReservation)} à ${DateFormatter.heure(r.datePaiement ?? r.dateReservation)}'),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          'Un agent va prendre votre dossier en charge. Suivez-le dans « Réservations ».',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
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
              for (final (libelleLigne, valeur) in lignes)
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
          label: 'Terminé',
          icon: Icons.check_rounded,
          onPressed: () => Navigator.of(context).pop(r),
        ),
      ],
    );
  }
}
