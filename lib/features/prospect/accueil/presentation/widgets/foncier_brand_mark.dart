import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';

/// Emblème Foncier+ : bâtiments posés sur des parcelles.
class FoncierBrandMark extends StatelessWidget {
  final double largeur;

  const FoncierBrandMark({super.key, this.largeur = 54});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largeur,
      height: largeur * 42 / 54,
      child: const CustomPaint(painter: _FoncierBrandMarkPainter()),
    );
  }
}

/// Version compacte du symbole officiel : bâtiments posés sur des parcelles.
class _FoncierBrandMarkPainter extends CustomPainter {
  const _FoncierBrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 54;
    final sy = size.height / 42;
    canvas.save();
    canvas.scale(sx, sy);

    final parcelPaint = Paint()
      ..color = AppColors.brandGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final parcel = Path()
      ..moveTo(2, 27)
      ..lineTo(27, 15)
      ..lineTo(52, 27)
      ..lineTo(27, 39)
      ..close();
    canvas.drawPath(parcel, parcelPaint);

    final parcelLines = Paint()
      ..color = AppColors.brandGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final lineOne = Path()
      ..moveTo(9, 27)
      ..lineTo(27, 18)
      ..lineTo(27, 34);
    final lineTwo = Path()
      ..moveTo(45, 27)
      ..lineTo(27, 18)
      ..moveTo(27, 34)
      ..lineTo(45, 27);
    canvas.drawPath(lineOne, parcelLines);
    canvas.drawPath(lineTwo, parcelLines);
    canvas.drawLine(const Offset(16, 30), const Offset(27, 35), parcelLines);
    canvas.drawLine(const Offset(38, 30), const Offset(27, 35), parcelLines);

    void building({
      required Path outline,
      required Color color,
      required Rect body,
      required List<Rect> windows,
    }) {
      final fill = Paint()..color = color;
      canvas.drawPath(outline, fill);
      canvas.drawRect(body, Paint()..color = color.withValues(alpha: 0.9));
      final windowPaint = Paint()..color = AppColors.white;
      for (final window in windows) {
        canvas.drawRect(window, windowPaint);
      }
    }

    // Petit bâtiment arrière gauche.
    building(
      outline: Path()
        ..moveTo(13, 14)
        ..lineTo(19, 10)
        ..lineTo(25, 14)
        ..lineTo(25, 25)
        ..lineTo(13, 25)
        ..close(),
      color: AppColors.brandGreen,
      body: const Rect.fromLTWH(13, 14, 12, 11),
      windows: const [Rect.fromLTWH(16, 16, 2, 3), Rect.fromLTWH(20, 16, 2, 3)],
    );

    // Bâtiment foncé à droite.
    building(
      outline: Path()
        ..moveTo(29, 8)
        ..lineTo(35, 4)
        ..lineTo(41, 8)
        ..lineTo(41, 23)
        ..lineTo(29, 23)
        ..close(),
      color: AppColors.primaryBlueAnthracite,
      body: const Rect.fromLTWH(29, 8, 12, 15),
      windows: const [Rect.fromLTWH(32, 11, 2, 3), Rect.fromLTWH(36, 11, 2, 3)],
    );

    // Maison mise en avant au premier plan.
    final house = Path()
      ..moveTo(20, 18)
      ..lineTo(27, 13)
      ..lineTo(34, 18)
      ..lineTo(34, 29)
      ..lineTo(20, 29)
      ..close();
    canvas.drawPath(house, Paint()..color = AppColors.brandGold);
    canvas.drawPath(
      Path()
        ..moveTo(20, 18)
        ..lineTo(27, 13)
        ..lineTo(34, 18),
      Paint()
        ..color = AppColors.brandGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(25, 22, 4, 7),
        const Radius.circular(0.7),
      ),
      Paint()..color = AppColors.primaryBlueAnthracite,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoncierBrandMarkPainter oldDelegate) => false;
}
