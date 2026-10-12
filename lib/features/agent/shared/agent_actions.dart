import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/contact_launcher.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';

/// Actions de contact/terrain partagées par les écrans agent.
class AgentActions {
  AgentActions._();

  static Future<void> appeler(BuildContext context, String? telephone) async {
    final ok = await ContactLauncher.appeler(telephone);
    if (!ok && context.mounted) {
      AppSnackbar.error(context, 'Impossible de lancer l\'appel.');
    }
  }

  /// Itinéraire / localisation : en attente de la finalisation côté backend.
  static void itineraireIndisponible(BuildContext context) =>
      AppSnackbar.info(context, 'Itinéraire bientôt disponible.');
}
