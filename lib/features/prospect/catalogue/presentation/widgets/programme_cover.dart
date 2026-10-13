import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';

/// Illustration de couverture d'une cité (plan stylisé) quand aucune photo n'est fournie.
class ProgrammeCover extends StatelessWidget {
  final int seed;

  const ProgrammeCover({super.key, required this.seed});

  static const List<Color> _teintes = [
    AppColors.mapCanvas,
    AppColors.mapDeepGreen,
    AppColors.mapParcel,
    AppColors.mapField,
  ];

  @override
  Widget build(BuildContext context) {
    final c1 = _teintes[seed % _teintes.length];
    final c2 = _teintes[(seed + 1) % _teintes.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(painter: _PlanPainter(seed: seed)),
    );
  }
}

/// Lotissement stylisé : îlots, voies et une parcelle mise en avant.
class _PlanPainter extends CustomPainter {
  final int seed;
  _PlanPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final trait = Paint()
      ..color = AppColors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final voie = Paint()
      ..color = AppColors.white.withValues(alpha: 0.28)
      ..strokeWidth = 6;
    final ilot = Paint()..color = AppColors.white.withValues(alpha: 0.10);
    final vedette = Paint()
      ..color = AppColors.primaryOcreLight.withValues(alpha: 0.85);

    // Voies principales
    final yVoie = size.height * (0.45 + (seed % 3) * 0.08);
    canvas.drawLine(Offset(0, yVoie), Offset(size.width, yVoie), voie);
    final xVoie = size.width * (0.35 + (seed % 4) * 0.08);
    canvas.drawLine(Offset(xVoie, 0), Offset(xVoie, size.height), voie);

    // Îlots découpés en lots
    const pas = 26.0;
    for (double x = 8; x < size.width - pas; x += pas) {
      for (double y = 8; y < size.height - pas; y += pas) {
        final rect = Rect.fromLTWH(x, y, pas - 6, pas - 6);
        if (rect.contains(Offset(xVoie, rect.center.dy)) ||
            rect.contains(Offset(rect.center.dx, yVoie))) {
          continue;
        }
        final r = RRect.fromRectAndRadius(rect, const Radius.circular(3));
        canvas.drawRRect(r, ilot);
        canvas.drawRRect(r, trait);
      }
    }

    // Lot mis en avant
    final lot = RRect.fromRectAndRadius(
      Rect.fromLTWH(xVoie + 12, yVoie + 12, pas - 6, pas - 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(lot, vedette);
  }

  @override
  bool shouldRepaint(covariant _PlanPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
