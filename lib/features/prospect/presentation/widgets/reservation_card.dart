import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/business_rules.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';

/// Carte d'une réservation de l'acquéreur : statut, bien, montant, compte à rebours et annulation.
class ReservationCard extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const ReservationCard({super.key, required this.reservation});

  @override
  ConsumerState<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends ConsumerState<ReservationCard> {
  bool _busy = false;

  Future<void> _annuler() async {
    setState(() => _busy = true);
    await annulerReservationAvecConfirmation(context, ref, widget.reservation);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final restant = BusinessRules.tempsRestantReservation(r.dateReservation);
    final expiree = r.isEnAttente && restant.inSeconds <= 0;

    final Color color;
    final String label;
    if (r.isAnnulee) {
      color = AppColors.grey600;
      label = 'Annulée';
    } else if (expiree) {
      color = AppColors.errorRed;
      label = 'Expirée';
    } else if (r.isEnAttente) {
      color = AppColors.ambreReservation24h;
      label = 'En attente';
    } else if (r.statut == 'CONFIRMER') {
      color = AppColors.successGreen;
      label = 'Confirmée';
    } else {
      color = AppColors.errorRed;
      label = 'Refusée';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'DOSSIER ${r.numeroDossier}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textSecondary),
                ),
              ),
              StatusPill(label: label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.bienDesignation ?? 'Bien non renseigné',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite),
          ),
          if ((r.programmeNom ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.apartment_rounded, size: 15, color: AppColors.primaryOcre),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(r.programmeNom!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _info('Montant', CurrencyFormatter.fcfa(r.montant), highlight: true)),
              Expanded(child: _info('Demandée le', DateFormatter.date(r.dateReservation))),
            ],
          ),
          if (r.isEnAttente && !expiree) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.ambreReservation24h.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: AppColors.ambreReservation24h),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'En attente de la société — délai restant : ${restant.inHours}h ${restant.inMinutes % 60}m',
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF9A5B00)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (r.statut == 'REFUSER' && (r.motifRefus ?? '').isNotEmpty && !r.isAnnulee) ...[
            const SizedBox(height: 12),
            Text('Motif : ${r.motifRefus}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.errorRed, fontWeight: FontWeight.w600)),
          ],
          if (r.isEnAttente) ...[
            const SizedBox(height: 14),
            DetailButton(
              label: 'Annuler la réservation',
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

  Widget _info(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: highlight ? AppColors.primaryOcre : AppColors.primaryBlueAnthracite,
          ),
        ),
      ],
    );
  }
}
