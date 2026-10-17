import 'package:url_launcher/url_launcher.dart';

/// Ouvre l'itinéraire dans Google Maps (application si installée, sinon navigateur) :
/// vers des coordonnées GPS, ou à défaut vers une adresse recherchée.
class ItineraireLauncher {
  ItineraireLauncher._();

  static Uri? lien({double? latitude, double? longitude, String? adresse}) {
    if (latitude != null && longitude != null) {
      return Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': '$latitude,$longitude'});
    }
    final texte = adresse?.trim() ?? '';
    if (texte.isEmpty) return null;
    return Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': '$texte, Mali'});
  }

  /// Renvoie false si aucune destination n'est connue ou si Google Maps n'a pas pu s'ouvrir.
  static Future<bool> ouvrir({double? latitude, double? longitude, String? adresse}) async {
    final uri = lien(latitude: latitude, longitude: longitude, adresse: adresse);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
