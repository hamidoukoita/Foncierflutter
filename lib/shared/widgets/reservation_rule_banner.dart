import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';

/// Explique à l'acquéreur la règle de réservation du bien (unique ou multiple),
/// réglée par la société promotrice.
class ReservationRuleBanner extends StatelessWidget {
  final bool? reservationMultiple;
  final bool isReserve;

  const ReservationRuleBanner({
    super.key,
    required this.reservationMultiple,
    this.isReserve = false,
  });

  @override
  Widget build(BuildContext context) {
    final multiple = reservationMultiple == true;
    final color = multiple ? AppColors.successGreen : AppColors.primaryBlueAnthracite;
    final String text;
    if (multiple) {
      text = isReserve
          ? 'Ce bien est déjà réservé, mais la société accepte plusieurs réservations : vous pouvez aussi faire une demande.'
          : 'La société accepte plusieurs réservations sur ce bien : d\'autres acquéreurs peuvent le réserver en même temps que vous.';
    } else {
      text = isReserve
          ? 'Réservation unique : ce bien a déjà une réservation active, il n\'accepte pas d\'autre demande pour le moment.'
          : 'Réservation unique : une seule réservation active à la fois sur ce bien.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(multiple ? Icons.groups_rounded : Icons.person_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, height: 1.35, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
