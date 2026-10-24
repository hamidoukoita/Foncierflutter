import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/regle_remboursement.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/confirm_dialog.dart';
import 'widgets/paiement_reservation_sheet.dart';

/// Parcours « Réserver » commun aux fiches lot, parcelle et maison :
/// conditions de la société (montant, durée), paiement Orange Money simulé, reçu,
/// puis rafraîchissement des listes. Renvoie true si la réservation a été enregistrée.
Future<bool> reserverBienAvecConfirmation(
  BuildContext context,
  WidgetRef ref, {
  required int bienId,
  required String libelle,
}) async {
  final user = ref.read(authProvider).user;
  if (user == null) {
    AppSnackbar.info(context, 'Connectez-vous pour réserver');
    return false;
  }

  final repo = ref.read(reservationRepositoryProvider);
  final ConditionsReservation conditions;
  try {
    conditions = await repo.conditions(bienId);
  } catch (e) {
    if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
    return false;
  }
  if (!context.mounted) return false;
  if (!conditions.reservable) {
    AppSnackbar.error(context, conditions.motifIndisponibilite ?? 'Ce bien n’est pas disponible à la réservation.');
    return false;
  }

  final reservation = await PaiementReservationSheet.afficher(
    context,
    libelle: libelle,
    conditions: conditions,
    reserver: () => repo.reserverBien(bienId, user.id),
  );
  // La feuille peut être fermée après le paiement : on rafraîchit dans tous les cas.
  _rafraichir(ref, bienId);
  return reservation != null;
}

void _rafraichir(WidgetRef ref, int? bienId) {
  ref.invalidate(mesReservationsProvider);
  ref.invalidate(prospectDashboardProvider);
  ref.invalidate(parcellesProvider);
  if (bienId != null) {
    ref.invalidate(bienDetailProvider(bienId));
    ref.invalidate(conditionsReservationProvider(bienId));
  }
}

/// Ma réservation encore active sur ce bien (null si aucune) : « Annuler » remplace alors « Réserver ».
ReservationModel? maReservationActive(List<ReservationModel>? mesReservations, int bienId) {
  if (mesReservations == null) return null;
  for (final r in mesReservations) {
    if (r.bienId == bienId && r.estActive) return r;
  }
  return null;
}

/// Désistement de l'acquéreur, avec confirmation : il est remboursé selon la règle de la société.
Future<bool> annulerReservationAvecConfirmation(
  BuildContext context,
  WidgetRef ref,
  ReservationModel reservation,
) async {
  final perte = reservation.estPayante ? '\n\n${RegleRemboursement.avantAnnulation(reservation)}' : '';
  final ok = await ConfirmDialog.show(
    context,
    icon: Icons.bookmark_remove_rounded,
    title: 'Annuler cette réservation ?',
    message: '${reservation.bienDesignation ?? 'Ce bien'} sera de nouveau proposé aux autres acquéreurs.$perte',
    confirmLabel: 'Annuler la réservation',
    cancelLabel: 'Garder',
    destructive: true,
  );
  if (!ok || !context.mounted) return false;

  try {
    await ref.read(reservationRepositoryProvider).annuler(reservation.id);
    _rafraichir(ref, reservation.bienId);
    if (context.mounted) AppSnackbar.success(context, 'Réservation annulée');
    return true;
  } catch (e) {
    if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
    return false;
  }
}

/// Annulation d'un rendez-vous de visite, avec confirmation.
Future<bool> annulerRendezVousAvecConfirmation(
    BuildContext context, WidgetRef ref, int rendezVousId) async {
  final ok = await ConfirmDialog.show(
    context,
    icon: Icons.event_busy_rounded,
    title: 'Annuler ce rendez-vous ?',
    message: 'La société promotrice sera informée de l’annulation.',
    confirmLabel: 'Annuler la visite',
    cancelLabel: 'Garder',
    destructive: true,
  );
  if (!ok || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(rendezVousRepositoryProvider).annuler(rendezVousId);
    ref.invalidate(mesVisitesProvider);
    ref.invalidate(conditionsReservationProvider);
    AppSnackbar.successSur(messenger, 'Rendez-vous annulé');
    return true;
  } catch (e) {
    AppSnackbar.errorSur(messenger, ErrorHandler.messageOf(e));
    return false;
  }
}
