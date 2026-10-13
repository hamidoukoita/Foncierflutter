/// Paramètres de la cartographie OpenStreetMap.
class MapConstants {
  MapConstants._();

  /// Tuiles OSM standard (gratuites, usage raisonnable — attribution obligatoire).
  static const String tuilesOsm =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Identifie l'application auprès des serveurs OSM (politique d'usage des tuiles).
  static const String userAgentPackage =
      'com.example.flutter_mobile_prospect_agent';

  static const String attribution = '© contributeurs OpenStreetMap';
  static const String urlCopyright = 'https://www.openstreetmap.org/copyright';

  static const double zoomBien = 16.5;
  static const double zoomCite = 15.5;
  static const double zoomApproximatif = 13;
  static const double zoomMin = 4;
  static const double zoomMax = 19;
}
