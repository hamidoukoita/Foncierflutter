import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_remplacement_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';

/// Choix de l'acquéreur quand le bien qu'il avait réservé a été vendu à un autre :
/// remboursement sous 24 h, ou report du montant payé sur un autre bien de la société.
class SuiteVenteActions {
  SuiteVenteActions._();

  /// Retourne true si le remboursement a été demandé.
  static Future<bool> rembourser(BuildContext context, WidgetRef ref, ReservationModel reservation) async {
    try {
      await ref.read(reservationRepositoryProvider).demanderRemboursement(reservation.id);
      _rafraichir(ref);
      if (context.mounted) {
        AppSnackbar.success(context,
            '${CurrencyFormatter.fcfa(reservation.montantReservation)} vous seront remboursés sur Orange Money sous 24 h.');
      }
      return true;
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
      return false;
    }
  }

  /// Retourne true si la réservation a été reportée sur [bien].
  static Future<bool> remplacer(
    BuildContext context,
    WidgetRef ref,
    ReservationModel reservation,
    BienRemplacementModel bien,
  ) async {
    try {
      await ref.read(reservationRepositoryProvider).remplacer(reservation.id, bien.id);
      _rafraichir(ref);
      if (context.mounted) {
        AppSnackbar.success(context, 'Votre réservation porte maintenant sur ${bien.libelleType.toLowerCase()} ${bien.designation}.');
      }
      return true;
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
      return false;
    }
  }

  static void _rafraichir(WidgetRef ref) {
    ref.invalidate(mesReservationsProvider);
    ref.invalidate(prospectDashboardProvider);
  }
}
