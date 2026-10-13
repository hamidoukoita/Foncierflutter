import 'dart:math' as math;

/// Distances géographiques (formule de Haversine) et leur affichage.
class GeoDistance {
  GeoDistance._();

  static const double _rayonTerreMetres = 6371000;

  static double _rad(double degres) => degres * math.pi / 180;

  /// Distance à vol d'oiseau entre deux points GPS, en mètres.
  static double metres(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * _rayonTerreMetres * math.asin(math.sqrt(a));
  }

  /// 450 → "450 m" ; 1240 → "1,2 km"
  static String format(double metres) {
    if (metres < 1000) return '${(metres / 10).round() * 10} m';
    return '${(metres / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }
}
