import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';

/// Visionneuse 360° native (image équirectangulaire) : glisser pour tourner, rotation lente automatique.
/// Aucune dépendance supplémentaire.
class PanoramaViewerScreen extends StatefulWidget {
  final List<MediaModel> panoramas;
  final int initialIndex;

  const PanoramaViewerScreen({super.key, required this.panoramas, this.initialIndex = 0});

  static Future<void> show(BuildContext context, List<MediaModel> panoramas, {int index = 0}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PanoramaViewerScreen(panoramas: panoramas, initialIndex: index),
      ),
    );
  }

  @override
  State<PanoramaViewerScreen> createState() => _PanoramaViewerScreenState();
}

class _PanoramaViewerScreenState extends State<PanoramaViewerScreen> {
  late int _index = widget.initialIndex;
  double _offset = 0; // décalage horizontal en pixels
  bool _auto = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (_auto && mounted) setState(() => _offset -= 0.8);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.panoramas[_index];
    final size = MediaQuery.of(context).size;
    // Image équirectangulaire 2:1 affichée à la hauteur de l'écran.
    final h = size.height;
    final w = h * 2;
    final dx = ((_offset % w) + w) % w;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) => setState(() => _auto = false),
            onPanUpdate: (d) => setState(() => _offset += d.delta.dx),
            onDoubleTap: () => setState(() => _auto = !_auto),
            child: ClipRect(
              child: Stack(
                children: [
                  for (final k in [-1, 0, 1])
                    Positioned(
                      left: dx + k * w,
                      top: 0,
                      width: w,
                      height: h,
                      child: CachedNetworkImage(
                        imageUrl: media.urlAbsolue,
                        fit: BoxFit.fill,
                        placeholder: (_, __) => const SizedBox.shrink(),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
                  _RoundBtn(
                    icon: _auto ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    onTap: () => setState(() => _auto = !_auto),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.panoramas.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < widget.panoramas.length; i++)
                          GestureDetector(
                            onTap: () => setState(() => _index = i),
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swipe_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Glissez pour tourner', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 42, height: 42, child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}
