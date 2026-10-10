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
    final n = (lot.numeroLot ?? '').trim();
    if (n.isEmpty) return 'L.${lot.id}';
    return n.toLowerCase().startsWith('l') ? n : 'L.$n';
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
  return base.inflate(pad);
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

  @override
  void paint(Canvas canvas, Size size) {
    if (!transparentBackground) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
        Paint()..color = const Color(0xFFEFEBE0),
      );
    }
    canvas.save();
    canvas.translate(-bounds.left, -bounds.top);

    for (final e in elements) {
      _paintElement(canvas, e);
    }
    for (final s in lots) {
      _paintLot(canvas, s);
    }
    canvas.restore();
  }

  void _paintElement(Canvas canvas, PlanElement e) {
    final g = e.geometry;
    if (e.isRoute && g.isLine) {
      final path = Path()..moveTo(g.points.first.dx, g.points.first.dy);
      for (final p in g.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      final goudron = e.type == 'ROUTE_GOUDRONNEE';
      final paint = Paint()
        ..color = goudron ? const Color(0xFF8E9AAF) : const Color(0xFFC9A36B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, paint);
      // Axe pointillé
      _dashed(
        canvas,
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        dash: 10,
        gap: 8,
      );
      return;
    }
    if (g.isPolygon) {
      final vert = e.type == 'ESPACE_VERT';
      final path = Path()..addPolygon(g.points, true);
      canvas.drawPath(path, Paint()..color = vert ? const Color(0xFFB7D8A6) : const Color(0xFFF6E3A1));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = vert ? const Color(0xFF4A7A56) : const Color(0xFFD9B44A),
      );
      if (showLabels) {
        _text(canvas, e.affichage, g.centroid, 16, const Color(0xFF1A2B4C), maxWidth: g.bounds.width);
      }
    } else if (g.isPoint) {
      final c = g.points.first;
      canvas.drawCircle(c, 15, Paint()..color = Colors.white);
      canvas.drawCircle(
        c,
        15,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF1A2B4C),
      );
      if (showLabels) _text(canvas, e.affichage, c.translate(0, 28), 15, const Color(0xFF1A2B4C), maxWidth: 140);
    }
  }

  void _paintLot(Canvas canvas, PlanLotShape s) {
    final actif = filtre == null || s.famille == filtre;
    final color = couleurFamille(s.famille);
    final path = Path()..addPolygon(s.geometry.points, true);

    canvas.drawPath(path, Paint()..color = color.withValues(alpha: actif ? 1 : 0.22));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = Color.lerp(color, Colors.black, 0.35)!.withValues(alpha: actif ? 1 : 0.25),
    );

    if (s.lot.id == selectedLotId) {
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
      if (m >= 34) {
        final fs = (m * 0.26).clamp(14.0, 38.0);
        final c = s.geometry.centroid;
        _text(canvas, s.etiquette, c.translate(0, -fs * 0.55), fs, Colors.white, bold: true, maxWidth: b.width);
        if (s.lot.superficie != null && m >= 60) {
          _text(canvas, '${s.lot.superficie!.toStringAsFixed(0)} m²', c.translate(0, fs * 0.6), fs * 0.62,
              Colors.white.withValues(alpha: 0.92),
              maxWidth: b.width);
        }
      }
    }
  }

  void _text(Canvas canvas, String text, Offset center, double size, Color color,
      {bool bold = false, double? maxWidth}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
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
