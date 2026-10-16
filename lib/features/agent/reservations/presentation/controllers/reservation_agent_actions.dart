import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/reservation_suivi.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/confirm_dialog.dart';

/// Actions de l'agent sur une réservation qu'il suit, avec confirmation et rafraîchissement.
class ReservationAgentActions {
  ReservationAgentActions._();

  /// Démarre le décompte : le bien est réservé à l'acquéreur pour la durée fixée par la société.
  static Future<void> demarrer(BuildContext context, WidgetRef ref, ReservationModel r) async {
    final duree = r.dureeReservationHeures == null
        ? 'la durée fixée par la société'
        : DateFormatter.dureeLisible(Duration(hours: r.dureeReservationHeures!));
    final ok = await ConfirmDialog.show(
      context,
      icon: Icons.timer_outlined,
      title: 'Démarrer la réservation ?',
      message: '${r.titreSuivi} sera réservé à ${r.acquereurNom ?? 'l’acquéreur'} pendant $duree. '
          'Sans vente conclue à l’échéance, la réservation expire et le bien redevient disponible.',
      confirmLabel: 'Démarrer',
    );
    if (!ok || !context.mounted) return;
    await _executer(context, ref, () => ref.read(reservationRepositoryProvider).demarrerDecompte(r.id),
        'Décompte démarré');
  }

  /// Conclut la vente avant l'échéance.
  static Future<void> vendre(BuildContext context, WidgetRef ref, ReservationModel r) async {
    final ok = await ConfirmDialog.show(
      context,
      icon: Icons.sell_outlined,
      title: 'Conclure la vente ?',
      message: '${r.titreSuivi} passera « vendu » à ${r.acquereurNom ?? 'l’acquéreur'}. '
          'Les autres réservations éventuelles sur ce bien seront remboursées.',
      confirmLabel: 'Marquer vendu',
    );
    if (!ok || !context.mounted) return;
    await _executer(context, ref, () => ref.read(reservationRepositoryProvider).conclureVente(r.id),
        'Vente conclue');
  }

  static Future<void> _executer(
    BuildContext context,
    WidgetRef ref,
    Future<Object?> Function() action,
    String succes,
  ) async {
    try {
      await action();
      if (context.mounted) AppSnackbar.success(context, succes);
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
    } finally {
      // Le serveur a pu faire expirer la réservation entre-temps : on resynchronise dans tous les cas.
      ref.invalidate(agentReservationsProvider);
    }
  }
}
