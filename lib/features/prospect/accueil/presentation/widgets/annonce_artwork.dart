import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_reseau.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/url_media.dart';

/// Vignette d'annonce : photo du bien, sinon illustration neutre.
class AnnonceArtwork extends StatelessWidget {
  final String? imageUrl;
  final bool estProgramme;
  final double largeur;
  final double hauteur;
  final BorderRadius rayon;

  const AnnonceArtwork({
    super.key,
    required this.imageUrl,
    required this.estProgramme,
    double taille = 96,
    double? largeur,
    double? hauteur,
    this.rayon = AppRadius.radiusLg,
  })  : largeur = largeur ?? taille,
        hauteur = hauteur ?? taille;

  @override
  Widget build(BuildContext context) {
    final remplacement = _ArtworkPlaceholder(isProgramme: estProgramme);
    final url = UrlMedia.absolue(imageUrl);
    return ClipRRect(
      borderRadius: rayon,
      child: SizedBox(
        width: largeur,
        height: hauteur,
        child: url != null
            ? ImageReseau(url: url, attente: remplacement)
            : remplacement,
      ),
    );
  }
}

/// Visuel neutre de remplacement lorsque l'API ne fournit pas de photo.
/// Il ne représente pas la géométrie réelle d'un bien.
class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder({required this.isProgramme});
  final bool isProgramme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TerrainArtworkPainter(isProgramme: isProgramme),
      child: Center(
        child: Icon(
          isProgramme ? Icons.grid_view_rounded : Icons.landscape_rounded,
          size: 27,
          color: AppColors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _TerrainArtworkPainter extends CustomPainter {
  const _TerrainArtworkPainter({required this.isProgramme});
  final bool isProgramme;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isProgramme
            ? const [AppColors.mapCanvas, AppColors.mapDeepGreen]
            : const [AppColors.mapField, AppColors.successGreen],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    if (isProgramme) {
      final road = Paint()
        ..color = AppColors.mapRoad.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.075;
      final roadPath = Path()
        ..moveTo(size.width * 0.02, size.height * 0.72)
        ..lineTo(size.width * 0.38, size.height * 0.48)
        ..lineTo(size.width * 0.72, size.height * 0.56)
        ..lineTo(size.width * 0.98, size.height * 0.25);
      canvas.drawPath(roadPath, road);

      final parcel = Paint()
        ..color = AppColors.mapParcel.withValues(alpha: 0.88);
      final line = Paint()
        ..color = AppColors.white.withValues(alpha: 0.74)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 3; col++) {
          final rect = Rect.fromLTWH(
            size.width * (0.08 + col * 0.285),
            size.height * (0.06 + row * 0.29),
            size.width * 0.22,
            size.height * 0.21,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            parcel,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            line,
          );
        }
      }
    } else {
      final rows = Paint()
        ..color = AppColors.white.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var i = 0; i < 5; i++) {
        final path = Path()
          ..moveTo(-size.width * 0.1, size.height * (0.18 + i * 0.17))
          ..quadraticBezierTo(
            size.width * 0.45,
            size.height * (0.05 + i * 0.17),
            size.width * 1.1,
            size.height * (0.2 + i * 0.17),
          );
        canvas.drawPath(path, rows);
      }
      final patch = Paint()
        ..color = AppColors.mapFieldLight.withValues(alpha: 0.5);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.26, size.height * 0.27),
          width: size.width * 0.4,
          height: size.height * 0.16,
        ),
        patch,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TerrainArtworkPainter oldDelegate) =>
      oldDelegate.isProgramme != isProgramme;
}
