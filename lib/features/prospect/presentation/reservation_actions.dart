import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
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
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
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
