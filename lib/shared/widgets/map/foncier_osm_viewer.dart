import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/map_constants.dart';
import 'foncier_map_marker.dart';
import 'osm_poi.dart';
import 'poi_map_marker.dart';

/// Carte OpenStreetMap Foncier+ : marqueur du bien + commodités.
/// Utilisable en plein écran (interactive) ou en aperçu (statique).
class FoncierOsmViewer extends StatelessWidget {
  final LatLng centre;
  final double zoom;
  final List<OsmPoi> pois;
  final Object? poiSelectionne;
  final bool interactive;
  final bool afficherAttribution;
  final MapController? controller;
  final ValueChanged<OsmPoi>? onPoiTap;

  /// Si renseigné, la vue initiale englobe le bien et ses commodités.
  final EdgeInsets? cadragePadding;

  const FoncierOsmViewer({
    super.key,
    required this.centre,
    this.zoom = MapConstants.zoomBien,
    this.pois = const [],
    this.poiSelectionne,
    this.interactive = true,
    this.afficherAttribution = true,
    this.controller,
    this.onPoiTap,
    this.cadragePadding,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: centre,
        initialZoom: zoom,
        initialCameraFit: (cadragePadding != null && pois.isNotEmpty)
            ? CameraFit.coordinates(
                coordinates: [centre, ...pois.map((p) => p.position)],
                padding: cadragePadding!,
                maxZoom: zoom,
              )
            : null,
        minZoom: MapConstants.zoomMin,
        maxZoom: MapConstants.zoomMax,
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: MapConstants.tuilesOsm,
          userAgentPackageName: MapConstants.userAgentPackage,
          maxNativeZoom: 19,
        ),
        MarkerLayer(
          markers: [
            for (final poi in pois)
              Marker(
                point: poi.position,
                width: PoiMapMarker.taille,
                height: PoiMapMarker.taille,
                child: GestureDetector(
                  onTap: onPoiTap == null ? null : () => onPoiTap!(poi),
                  child: Tooltip(
                    message: poi.libelle,
                    child: PoiMapMarker(
                      icone: poi.icone,
                      selectionne: poi.id == poiSelectionne,
                    ),
                  ),
                ),
              ),
            Marker(
              point: centre,
              width: FoncierMapMarker.largeur,
              height: FoncierMapMarker.hauteur,
              alignment: Alignment.topCenter,
              child: const FoncierMapMarker(),
            ),
          ],
        ),
        if (afficherAttribution)
          RichAttributionWidget(
            showFlutterMapAttribution: false,
            attributions: [
              TextSourceAttribution(
                MapConstants.attribution,
                onTap: () => launchUrl(Uri.parse(MapConstants.urlCopyright)),
              ),
            ],
          ),
      ],
    );
  }
}
