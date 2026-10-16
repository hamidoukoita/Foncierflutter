import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

/// Direction dans la sphère d'un panorama, en degrés : azimut (-180 → 180) et élévation (-90 → 90).
/// Même convention que la visionneuse web, pour que les points posés par la société tombent au même endroit.
class DirectionPanorama {
  final double azimut;
  final double elevation;
  const DirectionPanorama(this.azimut, this.elevation);
}

/// Projection d'une direction sur l'écran de la visionneuse (mêmes calculs que son rendu).
class PanoramaGeometrie {
  PanoramaGeometrie._();

  static const double _deg = math.pi / 180;

  static double normaliserAzimut(double azimut) {
    final a = ((azimut + 180) % 360 + 360) % 360 - 180;
    return a == -180 ? 180 : a;
  }

  /// Position à l'écran, ou null si la direction est derrière la caméra.
  static Offset? positionAEcran(DirectionPanorama d, {
    required double yaw,
    required double pitch,
    required double fov,
    required Size taille,
  }) {
    final lon = d.azimut * _deg;
    final lat = d.elevation * _deg;
    var dx = math.cos(lat) * math.sin(lon);
    var dy = math.sin(lat);
    var dz = -math.cos(lat) * math.cos(lon);
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final x1 = dx * cy - dz * sy;
    final z1 = dx * sy + dz * cy;
    dx = x1;
    dz = z1;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final y2 = dy * cp + dz * sp;
    final z2 = -dy * sp + dz * cp;
    dy = y2;
    dz = z2;
    if (dz >= -1e-6) return null;
    final tf = math.tan(fov / 2);
    final aspect = taille.width / taille.height;
    final vx = dx / -dz / (aspect * tf);
    final vy = dy / -dz / tf;
    return Offset((vx + 1) / 2 * taille.width, (1 - vy) / 2 * taille.height);
  }

  /// Orientation de caméra (yaw, pitch en radians) qui regarde dans cette direction.
  static (double, double) orientationVers(DirectionPanorama d) => (-d.azimut * _deg, d.elevation * _deg);
}
