import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/panorama_geometrie.dart';
import 'package:flutter_mobile_prospect_agent/data/models/lien_panorama_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/visite_virtuelle_model.dart';

/// Visionneuse 360° native, même principe que sur le web : image équirectangulaire projetée sur une sphère,
/// glisser pour regarder autour (haut/bas/gauche/droite) avec inertie, pincer pour zoomer.
/// Aucune dépendance supplémentaire ; l'état est propre à chaque ouverture (aucun état résiduel au retour).
/// Avec une visite (maison clé en main), on part de la pièce de départ et l'on change de pièce
/// uniquement en touchant les portes, avec un fondu ; le bouton « Pièces » oriente la vue vers les portes.
class PanoramaViewerScreen extends StatefulWidget {
  final List<MediaModel> panoramas;
  final int initialIndex;
  final VisiteVirtuelleModel visite;

  const PanoramaViewerScreen({
    super.key,
    required this.panoramas,
    this.initialIndex = 0,
    this.visite = VisiteVirtuelleModel.vide,
  });

  static Future<void> show(
    BuildContext context,
    List<MediaModel> panoramas, {
    int index = 0,
    VisiteVirtuelleModel visite = VisiteVirtuelleModel.vide,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PanoramaViewerScreen(
            panoramas: panoramas, initialIndex: index, visite: visite),
      ),
    );
  }

  @override
  State<PanoramaViewerScreen> createState() => _PanoramaViewerScreenState();
}

class _PanoramaViewerScreenState extends State<PanoramaViewerScreen>
    with SingleTickerProviderStateMixin {
  static const double _fovMin = 30 * math.pi / 180;
  static const double _fovMax = 100 * math.pi / 180;
  static const double _fovDefault = 75 * math.pi / 180;
  static const double _pitchMax = 85 * math.pi / 180;
  static const double _dureeFonduMs = 800;

  late final Ticker _ticker;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  late final bool _enVisite = widget.visite.active;
  late int _index = _enVisite
      ? widget.visite.indexDepart(widget.panoramas)
      : widget.initialIndex;

  /// Pièce réellement à l'écran ; [_index] passe à la suivante dès qu'on la demande.
  late int _affiche = _index;
  ui.Image? _image;
  ui.ImageShader? _shader;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Object? _error;
  bool _chargement = false;

  /// Pièce précédente, figée dans sa dernière vue et effacée en fondu au-dessus de la nouvelle.
  ui.Image? _ancienneImage;
  ui.ImageShader? _ancienShader;
  (double, double, double) _ancienneVue = (0, 0, _fovDefault);
  final ValueNotifier<double> _fondu = ValueNotifier<double>(0);

  double _yaw = 0, _pitch = 0, _fov = _fovDefault;
  double _vYaw = 0, _vPitch = 0;
  bool _auto = false;
  bool _touching = false;
  double _startFov = _fovDefault;
  double _viewHeight = 1;

  /// Orientation à prendre au chargement de la pièce suivante (vue d'arrivée du point suivi).
  (double, double)? _orientationArrivee;

  /// Orientation de la pièce à son arrivée, reprise par « Recentrer ».
  (double, double) _orientationInitiale = (0, 0);

  /// Orientation vers laquelle la vue tourne en douceur (porte choisie dans « Pièces »).
  (double, double)? _cible;

  List<LienPanoramaModel> get _points =>
      widget.visite.pointsDe(widget.panoramas[_affiche].id);

  /// Passe dans la pièce visée par le point, orienté selon la vue d'arrivée.
  void _suivre(LienPanoramaModel lien) {
    final cible = widget.panoramas.indexWhere((p) => p.id == lien.cibleId);
    if (cible < 0 || _chargement) return;
    final vue = widget.visite.vueArrivee(lien);
    _orientationArrivee =
        vue == null ? null : PanoramaGeometrie.orientationVers(vue);
    _index = cible;
    _load();
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _load();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _detacherFlux();
    _shader?.dispose();
    _image?.dispose();
    _libererAncienne();
    _repaint.dispose();
    _fondu.dispose();
    super.dispose();
  }

  void _detacherFlux() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  void _libererAncienne() {
    _ancienShader?.dispose();
    _ancienShader = null;
    _ancienneImage?.dispose();
    _ancienneImage = null;
  }

  ImageProvider _provider(MediaModel media) => ResizeImage(
        CachedNetworkImageProvider(media.urlAbsolue),
        width: 4096,
        allowUpscaling: false,
      );

  /// Charge la pièce courante ; la précédente reste affichée jusqu'à ce que la nouvelle soit prête.
  void _load() {
    _detacherFlux();
    setState(() {
      _error = null;
      _chargement = true;
    });
    final stream =
        _provider(widget.panoramas[_index]).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        final img = info.image.clone();
        final shader = ui.ImageShader(
          img,
          TileMode.repeated,
          TileMode.clamp,
          Matrix4.identity().storage,
        );
        final (yaw, pitch) = _orientationArrivee ?? (0.0, 0.0);
        _orientationArrivee = null;
        setState(() {
          if (_shader != null) {
            _libererAncienne();
            _ancienneImage = _image;
            _ancienShader = _shader;
            _ancienneVue = (_yaw, _pitch, _fov);
            _fondu.value = 1;
          }
          _image = img;
          _shader = shader;
          _affiche = _index;
          _chargement = false;
          _yaw = yaw;
          _pitch = pitch;
          _orientationInitiale = (yaw, pitch);
          _fov = _fovDefault;
          _vYaw = _vPitch = 0;
          _cible = null;
        });
        _prechargerVoisines();
      },
      onError: (e, _) {
        if (!mounted) return;
        setState(() {
          _chargement = false;
          // Une pièce reste affichée : on le signale sans quitter la visite.
          if (_shader == null) _error = e;
        });
        if (_shader != null) {
          AppSnackbar.error(context, 'Impossible de charger cette pièce. Réessayez.');
        }
      },
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  /// Les pièces accessibles depuis celle-ci sont téléchargées d'avance : le passage est immédiat.
  void _prechargerVoisines() {
    final cibles = _points.map((l) => l.cibleId).toSet();
    for (final media in widget.panoramas.where((p) => cibles.contains(p.id))) {
      precacheImage(_provider(media), context).ignore();
    }
  }

  void _regarderPorte(LienPanoramaModel porte) {
    final (yaw, pitch) = PanoramaGeometrie.orientationVers(
        DirectionPanorama(porte.azimut, porte.elevation));
    // Chemin le plus court autour de l'axe vertical.
    final ecart = math.atan2(math.sin(yaw - _yaw), math.cos(yaw - _yaw));
    _cible = (_yaw + ecart, pitch.clamp(-_pitchMax, _pitchMax));
    _vYaw = _vPitch = 0;
    if (_auto) setState(() => _auto = false);
  }

  Future<void> _ouvrirPieces() async {
    final media = widget.panoramas[_affiche];
    final porte = await showModalBottomSheet<LienPanoramaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (context) => _MenuPieces(
        piece: _titre(media),
        portes: [
          for (final l in _points)
            (l, VisiteVirtuelleModel.libellePorte(l, widget.panoramas))
        ],
      ),
    );
    if (porte != null && mounted) _regarderPorte(porte);
  }

  /// En visite, le nom de la pièce (« Salon », « Pièce 2 ») ; sinon le titre de la vue.
  String _titre(MediaModel media) {
    if (_enVisite) {
      return VisiteVirtuelleModel.nomPiece(widget.panoramas, media.id);
    }
    return media.titre?.isNotEmpty == true ? media.titre! : 'Vue 360°';
  }

  // ---------------------------------------------------------------- animation (inertie, rotation, fondu)

  Duration _last = Duration.zero;

  void _onTick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 16667.0).clamp(0.0, 4.0);
    _last = now;
    var changed = false;
    if (_ancienShader != null) {
      final reste = _fondu.value - dt * 16.667 / _dureeFonduMs;
      if (reste <= 0) {
        _fondu.value = 0;
        setState(_libererAncienne);
      } else {
        _fondu.value = reste;
      }
    }
    if (_touching) _cible = null;
    if (_cible case (final yaw, final pitch)) {
      final dYaw = yaw - _yaw, dPitch = pitch - _pitch;
      if (dYaw.abs() < 0.002 && dPitch.abs() < 0.002) {
        _yaw = yaw;
        _pitch = pitch;
        _cible = null;
      } else {
        final f = 1 - math.pow(0.88, dt).toDouble();
        _yaw += dYaw * f;
        _pitch += dPitch * f;
      }
      changed = true;
    } else if (!_touching) {
      if (_vYaw.abs() > 0.00005 || _vPitch.abs() > 0.00005) {
        final f = math.pow(0.92, dt).toDouble();
        _vYaw *= f;
        _vPitch *= f;
        _yaw += _vYaw * dt;
        _pitch = (_pitch + _vPitch * dt).clamp(-_pitchMax, _pitchMax);
        changed = true;
      } else if (_auto) {
        _yaw += 0.003 * dt;
        changed = true;
      }
    }
    if (changed) _repaint.value++;
  }

  void _onScaleStart(ScaleStartDetails d) {
    _touching = true;
    _vYaw = _vPitch = 0;
    _startFov = _fov;
    if (_auto) setState(() => _auto = false);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final k = _fov / _viewHeight;
    if (d.pointerCount >= 2) {
      _fov = (_startFov / d.scale).clamp(_fovMin, _fovMax);
    }
    _vYaw = -d.focalPointDelta.dx * k;
    _vPitch = d.focalPointDelta.dy * k;
    _yaw += _vYaw;
    _pitch = (_pitch + _vPitch).clamp(-_pitchMax, _pitchMax);
    _repaint.value++;
  }

  void _onScaleEnd(ScaleEndDetails d) {
    _touching = false; // l'inertie reprend avec la dernière vitesse
  }

  void _zoom(double factor) {
    _fov = (_fov * factor).clamp(_fovMin, _fovMax);
    _repaint.value++;
  }

  void _reset() {
    final (yaw, pitch) = _orientationInitiale;
    _yaw = yaw;
    _pitch = pitch;
    _fov = _fovDefault;
    _vYaw = _vPitch = 0;
    _cible = null;
    _repaint.value++;
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.panoramas[_affiche];
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A2B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              _viewHeight = c.maxHeight <= 0 ? 1 : c.maxHeight;
              if (_error != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image_outlined,
                          color: Colors.white54, size: 48),
                      const SizedBox(height: 12),
                      const Text('Impossible de charger le panorama.',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54)),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }
              if (_shader == null || _image == null) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE5801A)));
              }
              final taille = Size(c.maxWidth, c.maxHeight);
              final points = _points;
              return Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _PanoPainter(
                          repaint: _repaint,
                          shader: _shader!,
                          imgW: _image!.width.toDouble(),
                          imgH: _image!.height.toDouble(),
                          state: () => (_yaw, _pitch, _fov),
                        ),
                      ),
                    ),
                  ),
                  if (_ancienShader != null && _ancienneImage != null)
                    // Pièce précédente qui s'efface en fondu.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ValueListenableBuilder<double>(
                          valueListenable: _fondu,
                          builder: (context, opacite, child) => Opacity(
                              opacity: opacite.clamp(0.0, 1.0), child: child),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _PanoPainter(
                              repaint: _fondu,
                              shader: _ancienShader!,
                              imgW: _ancienneImage!.width.toDouble(),
                              imgH: _ancienneImage!.height.toDouble(),
                              state: () => _ancienneVue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (points.isNotEmpty)
                    // Les points suivent la vue : repositionnés à chaque image, comme le panorama.
                    ValueListenableBuilder<int>(
                      valueListenable: _repaint,
                      builder: (context, _, __) => Stack(
                        children: [
                          for (final lien in points)
                            if (PanoramaGeometrie.positionAEcran(
                              DirectionPanorama(lien.azimut, lien.elevation),
                              yaw: _yaw,
                              pitch: _pitch,
                              fov: _fov,
                              taille: taille,
                            )
                                case final position?)
                              Positioned(
                                key: ValueKey(lien.id),
                                left: position.dx - _PointPassage.largeur / 2,
                                top: position.dy - _PointPassage.rayon,
                                child: _PointPassage(
                                  libelle: VisiteVirtuelleModel.libellePorte(
                                      lien, widget.panoramas),
                                  onTap: () => _suivre(lien),
                                ),
                              ),
                        ],
                      ),
                    ),
                  if (_chargement)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                          minHeight: 2,
                          color: Color(0xFFE5801A),
                          backgroundColor: Colors.transparent),
                    ),
                ],
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _RoundBtn(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _titre(media),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ),
                    if (_enVisite && _shader != null) ...[
                      const SizedBox(width: 12),
                      _BoutonPieces(onTap: _ouvrirPieces),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_shader != null)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RoundBtn(
                          icon: Icons.add_rounded, onTap: () => _zoom(1 / 1.2)),
                      const SizedBox(height: 8),
                      _RoundBtn(
                          icon: Icons.remove_rounded, onTap: () => _zoom(1.2)),
                      const SizedBox(height: 8),
                      _RoundBtn(
                        icon: Icons.autorenew_rounded,
                        active: _auto,
                        onTap: () => setState(() {
                          _auto = !_auto;
                          _vYaw = _vPitch = 0;
                          _cible = null;
                        }),
                      ),
                      const SizedBox(height: 8),
                      _RoundBtn(icon: Icons.my_location_rounded, onTap: _reset),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hors visite, les vues se choisissent librement ; en visite, on passe par les portes.
                    if (!_enVisite && widget.panoramas.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < widget.panoramas.length; i++)
                              GestureDetector(
                                onTap: () {
                                  if (i == _index) return;
                                  _orientationArrivee = null;
                                  _index = i;
                                  _load();
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: i == _index ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _index
                                        ? const Color(0xFFE5801A)
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _enVisite
                            ? 'Glissez pour regarder autour · touchez une porte pour changer de pièce'
                            : 'Glissez pour regarder autour · pincez pour zoomer',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Projection : chaque sommet d'une grille d'écran lance un rayon (yaw/pitch/fov) converti en coordonnées
/// équirectangulaires ; le maillage texturé est dessiné d'un coup (même maths que le shader du web).
class _PanoPainter extends CustomPainter {
  final ui.ImageShader shader;
  final double imgW, imgH;
  final (double, double, double) Function() state;

  _PanoPainter({
    required Listenable repaint,
    required this.shader,
    required this.imgW,
    required this.imgH,
    required this.state,
  }) : super(repaint: repaint);

  static const int _cols = 40;
  static const int _rows = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final (yaw, pitch, fov) = state();
    final aspect = size.width / size.height;
    final tf = math.tan(fov / 2);
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final cy = math.cos(yaw), sy = math.sin(yaw);

    final nv = (_cols + 1) * (_rows + 1);
    final pos = Float32List(nv * 2);
    final tex = Float32List(nv * 2);
    var rowStartLon = 0.0;

    for (var j = 0; j <= _rows; j++) {
      final vy = 1 - 2 * j / _rows;
      var prevLon = 0.0;
      for (var i = 0; i <= _cols; i++) {
        final vx = 2 * i / _cols - 1;
        var dx = vx * aspect * tf;
        var dy = vy * tf;
        var dz = -1.0;
        final n = math.sqrt(dx * dx + dy * dy + dz * dz);
        dx /= n;
        dy /= n;
        dz /= n;
        final ndy = dy * cp - dz * sp;
        final ndz = dy * sp + dz * cp;
        dy = ndy;
        dz = ndz;
        final ndx2 = dx * cy + dz * sy;
        final ndz2 = -dx * sy + dz * cy;
        dx = ndx2;
        dz = ndz2;

        var lon = math.atan2(dx, -dz);
        final lat = math.asin(dy.clamp(-1.0, 1.0));
        if (i == 0) {
          if (j > 0) lon = _unwrap(lon, rowStartLon);
          rowStartLon = lon;
        } else {
          lon = _unwrap(lon, prevLon);
        }
        prevLon = lon;

        final k = (j * (_cols + 1) + i) * 2;
        pos[k] = i / _cols * size.width;
        pos[k + 1] = j / _rows * size.height;
        tex[k] = (lon / (2 * math.pi) + 0.5) * imgW;
        tex[k + 1] = (0.5 - lat / math.pi) * imgH;
      }
    }

    final idx = Uint16List(_cols * _rows * 6);
    var t = 0;
    for (var j = 0; j < _rows; j++) {
      for (var i = 0; i < _cols; i++) {
        final a = j * (_cols + 1) + i;
        final b = a + 1;
        final c = a + (_cols + 1);
        final d = c + 1;
        idx[t++] = a;
        idx[t++] = b;
        idx[t++] = c;
        idx[t++] = b;
        idx[t++] = d;
        idx[t++] = c;
      }
    }

    final vertices = ui.Vertices.raw(VertexMode.triangles, pos,
        textureCoordinates: tex, indices: idx);
    canvas.drawVertices(
      vertices,
      BlendMode.src,
      Paint()
        ..shader = shader
        ..filterQuality = FilterQuality.medium,
    );
    vertices.dispose();
  }

  static double _unwrap(double lon, double ref) {
    while (lon - ref > math.pi) {
      lon -= 2 * math.pi;
    }
    while (lon - ref < -math.pi) {
      lon += 2 * math.pi;
    }
    return lon;
  }

  @override
  bool shouldRepaint(covariant _PanoPainter old) => old.shader != shader;
}

/// Point de passage vers une autre pièce : pastille fléchée qui pulse, et nom de la pièce.
class _PointPassage extends StatefulWidget {
  static const double rayon = 22;
  static const double largeur = 140;

  final String libelle;
  final VoidCallback onTap;
  const _PointPassage({required this.libelle, required this.onTap});

  @override
  State<_PointPassage> createState() => _PointPassageState();
}

class _PointPassageState extends State<_PointPassage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulsation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  @override
  void dispose() {
    _pulsation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const diametre = _PointPassage.rayon * 2;
    return Semantics(
      button: true,
      label: 'Aller vers ${widget.libelle}',
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: _PointPassage.largeur,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: diametre,
                height: diametre,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Onde qui s'élargit et s'efface : le point se remarque dans l'image.
                    AnimatedBuilder(
                      animation: _pulsation,
                      builder: (context, _) => Transform.scale(
                        scale: 1 + _pulsation.value * 0.7,
                        child: Container(
                          width: diametre,
                          height: diametre,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white.withValues(
                                alpha: 0.55 * (1 - _pulsation.value)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: diametre,
                      height: diametre,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.35),
                              blurRadius: 10)
                        ],
                      ),
                      child: const Icon(Icons.north_rounded,
                          color: AppColors.primaryBlueAnthracite),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton « Pièces » de l'en-tête de visite.
class _BoutonPieces extends StatelessWidget {
  final VoidCallback onTap;
  const _BoutonPieces({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.door_front_door_outlined,
                  color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('Pièces',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feuille « Pièces » : où l'on est, et les portes de la pièce ; en choisir une tourne la vue vers elle.
class _MenuPieces extends StatelessWidget {
  final String piece;

  /// Chaque porte, avec le texte à afficher.
  final List<(LienPanoramaModel, String)> portes;
  const _MenuPieces({required this.piece, required this.portes});

  @override
  Widget build(BuildContext context) {
    // Défilant et limité en hauteur : la feuille tient aussi en paysage.
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VOUS ÊTES DANS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(piece,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlueAnthracite)),
              const SizedBox(height: 12),
              if (portes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Aucune porte dans cette pièce.',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                for (final (porte, libelle) in portes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.near_me_rounded,
                        color: AppColors.primaryOcre),
                    title: Text('Porte vers $libelle',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite)),
                    onTap: () => Navigator.of(context).pop(porte),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _RoundBtn(
      {required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? const Color(0xFFE5801A)
          : Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
            width: 44, height: 44, child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}
