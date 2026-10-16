import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/panorama_geometrie.dart';

void main() {
  const fov = 75 * 3.141592653589793 / 180;
  const taille = Size(400, 800);

  test('la direction regardée est au centre de l’écran', () {
    const d = DirectionPanorama(120, 15);
    final (yaw, pitch) = PanoramaGeometrie.orientationVers(d);
    final p = PanoramaGeometrie.positionAEcran(d, yaw: yaw, pitch: pitch, fov: fov, taille: taille)!;
    expect(p.dx, closeTo(200, 1e-6));
    expect(p.dy, closeTo(400, 1e-6));
  });

  test('un point derrière la caméra n’est pas affiché', () {
    expect(PanoramaGeometrie.positionAEcran(const DirectionPanorama(180, 0), yaw: 0, pitch: 0, fov: fov, taille: taille), isNull);
  });

  test('un point à droite apparaît à droite du centre', () {
    final p = PanoramaGeometrie.positionAEcran(const DirectionPanorama(20, 0), yaw: 0, pitch: 0, fov: fov, taille: taille)!;
    expect(p.dx, greaterThan(200));
    expect(p.dy, closeTo(400, 1e-6));
  });

  test('normalise l’azimut', () {
    expect(PanoramaGeometrie.normaliserAzimut(190), -170);
    expect(PanoramaGeometrie.normaliserAzimut(-180), 180);
  });
}
