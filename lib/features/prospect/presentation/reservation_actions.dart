import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';

/// Parcours « Réserver » commun aux écrans parcelle / lot :
/// confirmation, appel API, rafraîchissement des listes et message clair en cas de refus
/// (ex. bien en réservation unique déjà réservé : le backend renvoie le motif).
///
/// Renvoie true si la réservation a été enregistrée.
Future<bool> reserverBienAvecConfirmation(
  BuildContext context,
  WidgetRef ref, {
  required int bienId,
  required String libelle,
}) async {
  final user = ref.read(authProvider).user;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connectez-vous pour réserver')),
    );
    return false;
  }

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Réserver ce bien ?'),
      content: Text(
        '$libelle\n\nVotre demande sera transmise à la société promotrice, qui la confirmera ou la refusera. '
        'Suivez son avancement dans l\'onglet « Réservations ».',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Retour')),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Réserver', style: TextStyle(color: AppColors.primaryOcre, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  if (!context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(reservationRepositoryProvider).reserverBien(bienId, user.id);
    ref.invalidate(mesReservationsProvider);
    ref.invalidate(prospectDashboardProvider);
    ref.invalidate(parcellesProvider);
    ref.invalidate(bienDetailProvider(bienId));
    messenger.showSnackBar(const SnackBar(content: Text('Réservation enregistrée')));
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(ErrorHandler.messageOf(e)), backgroundColor: AppColors.errorRed),
    );
    return false;
  }
}


/// Ma réservation en attente sur ce bien (null si aucune) — permet d'afficher « Annuler » au lieu de « Réserver ».
ReservationModel? maReservationEnAttente(List<ReservationModel>? mesReservations, int bienId) {
  if (mesReservations == null) return null;
  for (final r in mesReservations) {
    if (r.bienId == bienId && r.isEnAttente) return r;
  }
  return null;
}

/// Annulation d'une réservation en attente, avec confirmation. Renvoie true si annulée.
Future<bool> annulerReservationAvecConfirmation(
  BuildContext context,
  WidgetRef ref,
  ReservationModel reservation,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Annuler cette réservation ?'),
      content: Text(
        '${reservation.bienDesignation ?? 'Ce bien'}\n\nLe bien sera de nouveau disponible pour les autres acquéreurs. '
        'Cette action est définitive.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Garder')),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Annuler la réservation',
              style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(reservationRepositoryProvider).annuler(reservation.id);
    ref.invalidate(mesReservationsProvider);
    ref.invalidate(prospectDashboardProvider);
    ref.invalidate(parcellesProvider);
    if (reservation.bienId != null) ref.invalidate(bienDetailProvider(reservation.bienId!));
    messenger.showSnackBar(const SnackBar(content: Text('Réservation annulée')));
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(ErrorHandler.messageOf(e)), backgroundColor: AppColors.errorRed),
    );
    return false;
  }
}

/// Annulation d'un rendez-vous de visite, avec confirmation.
Future<bool> annulerRendezVousAvecConfirmation(BuildContext context, WidgetRef ref, int rendezVousId) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Annuler ce rendez-vous ?'),
      content: const Text('La société promotrice sera informée de l\'annulation.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Garder')),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Annuler le rendez-vous',
              style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(rendezVousRepositoryProvider).annuler(rendezVousId);
    ref.invalidate(mesVisitesProvider);
    messenger.showSnackBar(const SnackBar(content: Text('Rendez-vous annulé')));
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(ErrorHandler.messageOf(e)), backgroundColor: AppColors.errorRed),
    );
    return false;
  }
}
