import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';

/// Lot + sa géométrie déjà décodée.
class PlanLotShape {
  final LotProgramme lot;
  final PlanGeometry geometry;
  const PlanLotShape(this.lot, this.geometry);

  LotFamille get famille => familleDeStatut(lot.statut);

  /// « L.104 » à partir du numéro de lot.
  String get etiquette {
    final n = (lot.numeroLot ?? '').trim().replaceFirst(RegExp(r'^Lot\s*N°\s*', caseSensitive: false), '');
    if (n.isEmpty) return 'L ${lot.id}';
    return 'L $n';
  }
}

List<PlanLotShape> lotsAvecGeometrie(List<LotProgramme> lots) {
  final out = <PlanLotShape>[];
  for (final l in lots) {
    final g = PlanGeometry.parse(l.geometryJson);
    if (g != null && g.isPolygon) out.add(PlanLotShape(l, g));
  }
  return out;
}

Rect _bounds(List<PlanLotShape> lots, List<PlanElement> elements, double pad) {
  Rect? r;
  void add(Rect b) => r = r == null ? b : r!.expandToInclude(b);
  for (final l in lots) {
    add(l.geometry.bounds);
  }
  for (final e in elements) {
    add(e.geometry.bounds);
  }
  final base = r ?? const Rect.fromLTWH(0, 0, 100, 100);
  return base.inflate(pad).expandToInclude(Rect.fromLTRB(base.left - pad, base.top - pad, base.right + pad, base.bottom + pad + 30));
}

/// Plan de masse interactif : zoom / déplacement, lots colorés par statut, tap pour sélectionner.
class PlanMasseView extends StatefulWidget {
  final List<PlanLotShape> lots;
  final List<PlanElement> elements;
  final int? selectedLotId;

  /// null = tous ; sinon seuls les lots de cette famille restent actifs (les autres sont estompés).
  final LotFamille? filtre;
  final ValueChanged<LotProgramme?> onLotTap;

  const PlanMasseView({
    super.key,
    required this.lots,
    required this.elements,
    required this.onLotTap,
    this.selectedLotId,
    this.filtre,
  });

  @override
  State<PlanMasseView> createState() => _PlanMasseViewState();
}

class _PlanMasseViewState extends State<PlanMasseView> {
  final TransformationController _controller = TransformationController();
  Size? _fittedFor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fit(Size viewport, Rect bounds) {
    if (_fittedFor == viewport) return;
    _fittedFor = viewport;
    final scale = math.min(viewport.width / bounds.width, viewport.height / bounds.height);
    final dx = (viewport.width - bounds.width * scale) / 2;
    final dy = (viewport.height - bounds.height * scale) / 2;
    _controller.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _bounds(widget.lots, widget.elements, 40);

    return LayoutBuilder(
      builder: (context, c) {
        final viewport = Size(c.maxWidth, c.maxHeight.isFinite ? c.maxHeight : c.maxWidth);
        _fit(viewport, bounds);

        return ClipRect(
          child: InteractiveViewer(
            transformationController: _controller,
            constrained: false,
            minScale: 0.2,
            maxScale: 8,
            boundaryMargin: const EdgeInsets.all(400),
            child: GestureDetector(
              onTapUp: (d) {
                final p = d.localPosition + bounds.topLeft;
                PlanLotShape? hit;
                for (final s in widget.lots.reversed) {
                  if (widget.filtre != null && s.famille != widget.filtre) continue;
                  if (s.geometry.contains(p)) {
                    hit = s;
                    break;
                  }
                }
                widget.onLotTap(hit?.lot);
              },
              child: CustomPaint(
                size: Size(bounds.width, bounds.height),
                painter: PlanMassePainter(
                  lots: widget.lots,
                  elements: widget.elements,
                  bounds: bounds,
                  selectedLotId: widget.selectedLotId,
                  filtre: widget.filtre,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Aperçu non interactif (fiche cité, vignette de lot).
class PlanMiniature extends StatelessWidget {
  final List<PlanLotShape> lots;
  final List<PlanElement> elements;
  final int? highlightLotId;
  final bool showLabels;

  const PlanMiniature({
    super.key,
    required this.lots,
    this.elements = const [],
    this.highlightLotId,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final bounds = _bounds(lots, elements, 24);
    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.contain,
        child: CustomPaint(
          size: Size(bounds.width, bounds.height),
          painter: PlanMassePainter(
            lots: lots,
            elements: elements,
            bounds: bounds,
            selectedLotId: highlightLotId,
            showLabels: showLabels,
            transparentBackground: true,
          ),
        ),
      ),
    );
  }
}

class PlanMassePainter extends CustomPainter {
  final List<PlanLotShape> lots;
  final List<PlanElement> elements;
  final Rect bounds;
  final int? selectedLotId;
  final LotFamille? filtre;
  final bool showLabels;
  final bool transparentBackground;

  PlanMassePainter({
    required this.lots,
    required this.elements,
    required this.bounds,
    this.selectedLotId,
    this.filtre,
    this.showLabels = true,
    this.transparentBackground = false,
  });

  // Couleurs identiques au Studio plan de masse du web.
  static const _bg = Color(0xFFF8F7F2);
  static const _navy = Color(0xFF1A2B4C);

  @override
  void paint(Canvas canvas, Size size) {
    if (!transparentBackground) {
      canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    }
    canvas.save();
    canvas.translate(-bounds.left, -bounds.top);

    final tries = [...elements]..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    // Même ordre que le web : zones vertes, routes, équipements, puis lots par-dessus.
    for (final e in tries) {
      if (e.type == 'ESPACE_VERT') _paintGreen(canvas, e);
    }
    for (final e in tries) {
      if (e.isRoute) _paintRoad(canvas, e);
    }
    for (final e in tries) {
      if (e.type != 'ESPACE_VERT' && !e.isRoute) _paintPoi(canvas, e);
    }
    for (final s in lots) {
      _paintLot(canvas, s);
    }
    canvas.restore();
  }

  void _paintGreen(Canvas canvas, PlanElement e) {
    final g = e.geometry;
    if (g.points.length < 3) return;
    final path = Path()..addPolygon(g.points, true);
    canvas.drawPath(path, Paint()..color = const Color(0xFFA9C59A));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF4A7A56),
    );
  }

  void _paintRoad(Canvas canvas, PlanElement e) {
    final g = e.geometry;
    if (g.points.length < 2) return;
    final path = Path()..moveTo(g.points.first.dx, g.points.first.dy);
    for (final p in g.points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final goudron = e.type == 'ROUTE_GOUDRONNEE';
    final paint = Paint()
      ..color = goudron ? const Color(0xFF334155) : const Color(0xFFA9773F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (goudron) {
      canvas.drawPath(path, paint);
    } else {
      _dashed(canvas, path, paint..strokeCap = StrokeCap.butt, dash: 10, gap: 8);
    }
  }

  void _paintPoi(Canvas canvas, PlanElement e) {
    final g = e.geometry;
    final c = g.isPoint ? g.points.first : g.centroid;
    canvas.drawCircle(c, 18, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _navy,
    );
    _icon(canvas, _poiIcon(e.type), c, 20, _navy);
    if (showLabels && (e.nom ?? '').trim().isNotEmpty) {
      _text(canvas, e.nom!.trim(), c.translate(0, 32), 15, _navy, bold: true, maxWidth: 160);
    }
  }

  static IconData _poiIcon(String type) {
    switch (type) {
      case 'MOSQUEE':
        return Icons.mosque_outlined;
      case 'EGLISE':
        return Icons.church_outlined;
      case 'ECOLE':
        return Icons.school_outlined;
      case 'MARCHE':
        return Icons.storefront_outlined;
      case 'COMMERCE':
        return Icons.shopping_bag_outlined;
      case 'EQUIPEMENT_PUBLIC':
        return Icons.local_hospital_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  void _paintLot(Canvas canvas, PlanLotShape s) {
    final actif = filtre == null || s.famille == filtre;
    final color = couleurFamille(s.famille);
    final path = Path()..addPolygon(s.geometry.points, true);
    final isSel = s.lot.id == selectedLotId;

    if (actif) {
      canvas.drawPath(path.shift(const Offset(0, 3)),
          Paint()..color = Colors.black.withValues(alpha: 0.12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: actif ? 1 : 0.2));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: actif ? 1 : 0.4),
    );

    if (isSel) {
      _dashed(
        canvas,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = const Color(0xFFE5801A),
        dash: 12,
        gap: 8,
      );
    }

    if (showLabels && actif) {
      final b = s.geometry.bounds;
      final m = math.min(b.width, b.height);
      if (m >= 22) {
        final fs = math.min(18.0, m * 0.42);
        _text(canvas, s.etiquette, s.geometry.centroid, fs, _navy, bold: true, maxWidth: b.width, heavy: true);
      }
    }
  }

  void _icon(Canvas canvas, IconData icon, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: size, fontFamily: icon.fontFamily, package: icon.fontPackage, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _text(Canvas canvas, String text, Offset center, double size, Color color,
      {bool bold = false, double? maxWidth, bool heavy = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: heavy ? FontWeight.w900 : (bold ? FontWeight.w800 : FontWeight.w700),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? 200);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _dashed(Canvas canvas, Path path, Paint paint, {required double dash, required double gap}) {
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PlanMassePainter old) =>
      old.lots != lots ||
      old.elements != elements ||
      old.selectedLotId != selectedLotId ||
      old.filtre != filtre ||
      old.bounds != bounds ||
      old.showLabels != showLabels;
}
