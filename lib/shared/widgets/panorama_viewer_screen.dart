import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';

/// Visionneuse 360° native, même principe que sur le web : image équirectangulaire projetée sur une sphère,
/// glisser pour regarder autour (haut/bas/gauche/droite) avec inertie, pincer pour zoomer.
/// Aucune dépendance supplémentaire ; l'état est propre à chaque ouverture (aucun état résiduel au retour).
class PanoramaViewerScreen extends StatefulWidget {
  final List<MediaModel> panoramas;
  final int initialIndex;

  const PanoramaViewerScreen({super.key, required this.panoramas, this.initialIndex = 0});

  static Future<void> show(BuildContext context, List<MediaModel> panoramas, {int index = 0}) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PanoramaViewerScreen(panoramas: panoramas, initialIndex: index),
      ),
    );
  }

  @override
  State<PanoramaViewerScreen> createState() => _PanoramaViewerScreenState();
}

class _PanoramaViewerScreenState extends State<PanoramaViewerScreen> with SingleTickerProviderStateMixin {
  static const double _fovMin = 30 * math.pi / 180;
  static const double _fovMax = 100 * math.pi / 180;
  static const double _fovDefault = 75 * math.pi / 180;
  static const double _pitchMax = 85 * math.pi / 180;

  late final Ticker _ticker;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  late int _index = widget.initialIndex;
  ui.Image? _image;
  ui.ImageShader? _shader;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Object? _error;

  double _yaw = 0, _pitch = 0, _fov = _fovDefault;
  double _vYaw = 0, _vPitch = 0;
  bool _auto = false;
  bool _touching = false;
  double _startFov = _fovDefault;
  double _viewHeight = 1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _load();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _release();
    _repaint.dispose();
    super.dispose();
  }

  void _release() {
    if (_stream != null && _listener != null) _stream!.removeListener(_listener!);
    _stream = null;
    _listener = null;
    _shader?.dispose();
    _shader = null;
    _image?.dispose();
    _image = null;
  }

  void _load() {
    _release();
    setState(() => _error = null);
    final provider = ResizeImage(
      CachedNetworkImageProvider(widget.panoramas[_index].urlAbsolue),
      width: 4096,
      allowUpscaling: false,
    );
    final stream = provider.resolve(ImageConfiguration.empty);
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
        setState(() {
          _image = img;
          _shader = shader;
          _yaw = 0;
          _pitch = 0;
          _fov = _fovDefault;
          _vYaw = _vPitch = 0;
        });
      },
      onError: (e, _) {
        if (mounted) setState(() => _error = e);
      },
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  // ---------------------------------------------------------------- animation (inertie + rotation auto)

  Duration _last = Duration.zero;

  void _onTick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 16667.0).clamp(0.0, 4.0);
    _last = now;
    var changed = false;
    if (!_touching) {
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
    _yaw = 0;
    _pitch = 0;
    _fov = _fovDefault;
    _vYaw = _vPitch = 0;
    _repaint.value++;
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.panoramas[_index];
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
                      const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                      const SizedBox(height: 12),
                      const Text('Impossible de charger le panorama.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }
              if (_shader == null || _image == null) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFE5801A)));
              }
              return GestureDetector(
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
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _RoundBtn(icon: Icons.close_rounded, onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      media.titre?.isNotEmpty == true ? media.titre! : 'Vue 360°',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ],
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
                      _RoundBtn(icon: Icons.add_rounded, onTap: () => _zoom(1 / 1.2)),
                      const SizedBox(height: 8),
                      _RoundBtn(icon: Icons.remove_rounded, onTap: () => _zoom(1.2)),
                      const SizedBox(height: 8),
                      _RoundBtn(
                        icon: Icons.autorenew_rounded,
                        active: _auto,
                        onTap: () => setState(() {
                          _auto = !_auto;
                          _vYaw = _vPitch = 0;
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
                    if (widget.panoramas.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < widget.panoramas.length; i++)
                              GestureDetector(
                                onTap: () {
                                  if (i == _index) return;
                                  _index = i;
                                  _load();
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: i == _index ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _index ? const Color(0xFFE5801A) : Colors.white54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Glissez pour regarder autour · pincez pour zoomer',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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

    final vertices = ui.Vertices.raw(VertexMode.triangles, pos, textureCoordinates: tex, indices: idx);
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

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _RoundBtn({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFFE5801A) : Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}
