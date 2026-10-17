import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/contact_launcher.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/itineraire_launcher.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
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

  /// Itinéraire Google Maps vers un bien : ses coordonnées, sinon celles de sa cité,
  /// sinon l'adresse connue ([adresseSecours], par exemple le lieu d'un rendez-vous au siège).
  static Future<void> itineraire(BuildContext context, {int? bienId, String? adresseSecours}) async {
    final container = ProviderScope.containerOf(context, listen: false);
    double? lat, lng;
    String? adresse = adresseSecours;
    try {
      if (bienId != null) {
        final bien = await container.read(bienFoncierRepositoryProvider).getById(bienId);
        lat = bien.latitude;
        lng = bien.longitude;
        adresse = bien.localisation ?? adresse;
        if ((lat == null || lng == null) && bien.programmeId != null) {
          final programme = await container.read(programmeRepositoryProvider).getById(bien.programmeId!);
          lat = programme.latitude;
          lng = programme.longitude;
          adresse = programme.lieu ?? adresse;
        }
      }
    } catch (_) {
      // Bien introuvable : on tente l'adresse de secours.
    }
    final ok = await ItineraireLauncher.ouvrir(latitude: lat, longitude: lng, adresse: adresse);
    if (!ok && context.mounted) {
      AppSnackbar.error(context, 'Localisation inconnue pour ce lieu.');
    }
  }
}
