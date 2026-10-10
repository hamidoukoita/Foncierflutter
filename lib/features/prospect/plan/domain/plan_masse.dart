import 'dart:convert';
import 'dart:ui';

/// Géométrie telle qu'enregistrée par le Studio plan de masse :
/// `{"type":"POLYGON"|"LINE","points":[{"x":..,"y":..}]}` ou `{"type":"POINT","x":..,"y":..}`.
class PlanGeometry {
  final String type; // POLYGON | LINE | POINT
  final List<Offset> points;

  const PlanGeometry(this.type, this.points);

  bool get isPolygon => type == 'POLYGON' && points.length >= 3;
  bool get isLine => type == 'LINE' && points.length >= 2;
  bool get isPoint => type == 'POINT' && points.isNotEmpty;

  static PlanGeometry? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final j = jsonDecode(raw);
      if (j is! Map) return null;
      final type = (j['type'] ?? 'POLYGON').toString().toUpperCase();
      if (type == 'POINT') {
        final x = (j['x'] as num?)?.toDouble();
        final y = (j['y'] as num?)?.toDouble();
        if (x == null || y == null) return null;
        return PlanGeometry('POINT', [Offset(x, y)]);
      }
      final list = j['points'];
      if (list is! List) return null;
      final pts = <Offset>[];
      for (final p in list) {
        if (p is Map && p['x'] is num && p['y'] is num) {
          pts.add(Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()));
        }
      }
      if (pts.isEmpty) return null;
      return PlanGeometry(type, pts);
    } catch (_) {
      return null;
    }
  }

  Rect get bounds {
    var minX = points.first.dx, maxX = points.first.dx;
    var minY = points.first.dy, maxY = points.first.dy;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Offset get centroid {
    var sx = 0.0, sy = 0.0;
    for (final p in points) {
      sx += p.dx;
      sy += p.dy;
    }
    return Offset(sx / points.length, sy / points.length);
  }

  /// Test point-dans-polygone (lancer de rayon).
  bool contains(Offset p) {
    if (!isPolygon) return false;
    var inside = false;
    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      final a = points[i], b = points[j];
      final crosses = (a.dy > p.dy) != (b.dy > p.dy) &&
          p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx;
      if (crosses) inside = !inside;
    }
    return inside;
  }
}

/// Élément non-lot du plan : route, espace vert, mosquée, école, marché…
class PlanElement {
  final int id;
  final String type; // ROUTE_GOUDRONNEE, ROUTE_NON_GOUDRONNEE, MOSQUEE, EGLISE, ECOLE, ESPACE_VERT, MARCHE, COMMERCE, EQUIPEMENT_PUBLIC, AUTRE
  final String? nom;
  final PlanGeometry geometry;
  final bool visible;
  final int zIndex;

  const PlanElement({
    required this.id,
    required this.type,
    required this.geometry,
    this.nom,
    this.visible = true,
    this.zIndex = 0,
  });

  bool get isRoute => type == 'ROUTE_GOUDRONNEE' || type == 'ROUTE_NON_GOUDRONNEE';

  String get libelle {
    switch (type) {
      case 'ROUTE_GOUDRONNEE':
        return 'Route goudronnée';
      case 'ROUTE_NON_GOUDRONNEE':
        return 'Route non goudronnée';
      case 'MOSQUEE':
        return 'Mosquée';
      case 'EGLISE':
        return 'Église';
      case 'ECOLE':
        return 'École';
      case 'ESPACE_VERT':
        return 'Espace vert';
      case 'MARCHE':
        return 'Marché';
      case 'COMMERCE':
        return 'Commerce';
      case 'EQUIPEMENT_PUBLIC':
        return 'Équipement public';
      default:
        return 'Point d\'intérêt';
    }
  }

  /// Nom saisi par la société, sinon libellé du type.
  String get affichage => (nom != null && nom!.trim().isNotEmpty) ? nom!.trim() : libelle;

  static PlanElement? fromJson(Map<String, dynamic> json) {
    final geo = PlanGeometry.parse(json['geometryJson'] as String?);
    if (geo == null) return null;
    return PlanElement(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'AUTRE',
      nom: json['nom'] as String?,
      geometry: geo,
      visible: json['visible'] as bool? ?? true,
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlanMasse {
  final int id;
  final String? description;
  final List<PlanElement> elements;

  const PlanMasse({required this.id, this.description, this.elements = const []});
}

/// Statut d'un lot (backend) ramené à 4 familles pour les couleurs et filtres.
enum LotFamille { libre, reserve, vendu, indisponible }

LotFamille familleDeStatut(String? statut) {
  final s = (statut ?? '').toUpperCase();
  if (s.contains('RESERV')) return LotFamille.reserve;
  if (s.contains('VENDU')) return LotFamille.vendu;
  if (s.startsWith('DISPON') || s == 'LIBRE' || s == 'PUBLIE') return LotFamille.libre;
  return LotFamille.indisponible;
}

Color couleurFamille(LotFamille f) {
  switch (f) {
    case LotFamille.libre:
      return const Color(0xFF2E7D32);
    case LotFamille.reserve:
      return const Color(0xFFE5801A);
    case LotFamille.vendu:
      return const Color(0xFFD73535);
    case LotFamille.indisponible:
      return const Color(0xFF94A3B8);
  }
}

String libelleFamille(LotFamille f) {
  switch (f) {
    case LotFamille.libre:
      return 'Disponible';
    case LotFamille.reserve:
      return 'Réservé';
    case LotFamille.vendu:
      return 'Vendu';
    case LotFamille.indisponible:
      return 'Indisponible';
  }
}
