import 'programme_foncier.dart';

/// Zone géographique et nombre de cités qu'elle regroupe.
class ZoneExploration {
  final String nom;
  final int nombreCites;
  const ZoneExploration(this.nom, this.nombreCites);
}

/// Déduit les zones à explorer à partir du libellé « lieu » des cités.
/// « Bamako, Banankabougou » → Banankabougou ; « Kati (Goudron 200m) » → Kati.
class ZonesExploration {
  ZonesExploration._();

  static const String _ville = 'bamako';

  static String? zoneDe(String? lieu) {
    if (lieu == null || lieu.trim().isEmpty) return null;
    final sansParentheses = lieu.replaceAll(RegExp(r'\(.*?\)'), '');
    final morceaux = sansParentheses
        .split(',')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
    if (morceaux.isEmpty) return null;
    // Le quartier est plus parlant que « Bamako » quand il est précisé.
    final precis = morceaux.where((m) => m.toLowerCase() != _ville).toList();
    return precis.isNotEmpty ? precis.first : morceaux.first;
  }

  /// Zones triées par nombre de cités décroissant puis par nom.
  static List<ZoneExploration> depuisProgrammes(
      List<ProgrammeFoncier> programmes) {
    final compte = <String, int>{};
    for (final p in programmes) {
      final zone = zoneDe(p.lieu);
      if (zone != null) compte[zone] = (compte[zone] ?? 0) + 1;
    }
    final zones =
        compte.entries.map((e) => ZoneExploration(e.key, e.value)).toList()
          ..sort((a, b) {
            final parNombre = b.nombreCites.compareTo(a.nombreCites);
            return parNombre != 0 ? parNombre : a.nom.compareTo(b.nom);
          });
    return zones;
  }
}
