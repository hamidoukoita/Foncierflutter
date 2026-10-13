import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/map_constants.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/map/foncier_osm_viewer.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/map/osm_poi.dart';
import '../../domain/commodite_icone.dart';
import '../../domain/lieu_carte.dart';
import 'localisation_panel.dart';
import 'map_top_bar.dart';

/// Carte plein écran interactive : bien, commodités et panneau d'informations.
class LocalisationMapView extends StatefulWidget {
  final LieuCarte lieu;

  const LocalisationMapView({super.key, required this.lieu});

  @override
  State<LocalisationMapView> createState() => _LocalisationMapViewState();
}

class _LocalisationMapViewState extends State<LocalisationMapView> {
  static const EdgeInsets _cadrage = EdgeInsets.fromLTRB(56, 140, 56, 300);

  final MapController _controller = MapController();
  Object? _selection;

  LatLng get _centre => widget.lieu.position!;

  double get _zoom => switch (widget.lieu.precision) {
        PrecisionPosition.commune => MapConstants.zoomApproximatif,
        PrecisionPosition.centreDesLots => MapConstants.zoomCite,
        _ => MapConstants.zoomBien,
      };

  List<OsmPoi> get _pois => [
        for (final item in widget.lieu.commodites)
          if (item.commodite.estGeolocalisee)
            OsmPoi(
              id: item.commodite.id,
              position:
                  LatLng(item.commodite.latitude!, item.commodite.longitude!),
              icone: CommoditeIcone.de(item.commodite),
              libelle: item.commodite.nom,
            ),
      ];

  void _focaliser(Object id, LatLng? position) {
    setState(() => _selection = id);
    if (position == null) return;
    _controller.fitCamera(
      CameraFit.coordinates(
          coordinates: [_centre, position], padding: _cadrage),
    );
  }

  void _recentrer() {
    setState(() => _selection = null);
    _controller.move(_centre, _zoom);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lieu = widget.lieu;
    return Stack(
      children: [
        Positioned.fill(
          child: FoncierOsmViewer(
            centre: _centre,
            zoom: _zoom,
            pois: _pois,
            poiSelectionne: _selection,
            controller: _controller,
            cadragePadding: _cadrage,
            onPoiTap: (poi) => _focaliser(poi.id, poi.position),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: MapTopBar(titre: lieu.titre, sousTitre: lieu.sousTitre),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: CircleIconButton(
                  icon: Icons.my_location_rounded,
                  onPressed: _recentrer,
                ),
              ),
              LocalisationPanel(
                lieu: lieu,
                selection: _selection,
                onSelectCommodite: (item) => _focaliser(
                  item.commodite.id,
                  item.commodite.estGeolocalisee
                      ? LatLng(
                          item.commodite.latitude!, item.commodite.longitude!)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
