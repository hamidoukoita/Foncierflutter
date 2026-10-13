import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

/// Point d'intérêt secondaire affiché sur une carte (commodité…).
class OsmPoi {
  final Object id;
  final LatLng position;
  final IconData icone;
  final String libelle;

  const OsmPoi({
    required this.id,
    required this.position,
    required this.icone,
    required this.libelle,
  });
}
