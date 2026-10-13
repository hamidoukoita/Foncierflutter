import 'package:latlong2/latlong.dart';

/// Centres approximatifs des principales localités du District de Bamako
/// et des cercles périphériques. Sert uniquement de repli quand un bien
/// n'a pas de coordonnées GPS : la position est alors signalée comme approximative.
class CommunesReference {
  CommunesReference._();

  static final Map<String, LatLng> _centres = {
    'sanankoroba': const LatLng(12.393, -7.927),
    'samanko': const LatLng(12.540, -8.070),
    'kalaban': const LatLng(12.560, -7.990),
    'senou': const LatLng(12.530, -7.950),
    'yirimadio': const LatLng(12.596, -7.930),
    'sotuba': const LatLng(12.660, -7.930),
    'moribabougou': const LatLng(12.700, -7.880),
    'baguineda': const LatLng(12.600, -7.780),
    'koulikoro': const LatLng(12.863, -7.560),
    'kati': const LatLng(12.744, -8.073),
    'bamako': const LatLng(12.639, -8.003),
  };

  /// Cherche une localité connue dans un libellé libre (« Cité X, Kati »).
  static LatLng? depuisLibelle(String? libelle) {
    if (libelle == null || libelle.trim().isEmpty) return null;
    final texte = _normaliser(libelle);
    for (final entree in _centres.entries) {
      if (texte.contains(entree.key)) return entree.value;
    }
    return null;
  }

  static String _normaliser(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ûüù]'), 'u');
}
