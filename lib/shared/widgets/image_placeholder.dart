import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

/// Vignette d'attente (bordure pointillée) en l'absence de photo du bien.
class ImagePlaceholder extends StatelessWidget {
  final double size;
  final IconData icon;

  const ImagePlaceholder({
    super.key,
    this.size = 64,
    this.icon = Icons.map_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.placeholderSurface,
          borderRadius: AppRadius.radiusLg,
        ),
        child: Icon(icon,
            color: AppColors.primaryBlueAnthracite, size: size * 0.35),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(AppRadius.lg),
      ));
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
