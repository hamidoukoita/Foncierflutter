import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/panorama_viewer_screen.dart';

/// En-tête visuel d'une cité ou d'un lot : photo(s) réelles, bouton retour,
/// bouton « 360° » en haut à droite lorsqu'un panorama est téléversé, bouton visite virtuelle.
/// Sans photo : dégradé de marque (aucune image inventée).
class HeroMedia extends StatefulWidget {
  final List<MediaModel> medias;
  final bool loading;
  final double height;
  final VoidCallback onBack;
  final Widget? overlay; // contenu en bas de l'image (ex. numéro de lot)

  const HeroMedia({
    super.key,
    required this.medias,
    required this.onBack,
    this.loading = false,
    this.height = 240,
    this.overlay,
  });

  @override
  State<HeroMedia> createState() => _HeroMediaState();
}

class _HeroMediaState extends State<HeroMedia> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final photos = widget.medias.where((m) => m.isPhoto).toList();
    final panos = widget.medias.where((m) => m.isPanorama).toList();
    final visites = widget.medias.where((m) => m.isVisiteVirtuelle).toList();

    return SizedBox(
      height: widget.height + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photos.isEmpty)
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlueAnthracite, AppColors.mapDeepGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: widget.loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2))
                  : null,
            )
          else
            PageView.builder(
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: photos[i].urlAbsolue,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.grey200),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.grey200,
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.grey400, size: 36),
                ),
              ),
            ),
          // dégradé pour la lisibilité des boutons
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: top + 8,
            left: 12,
            child: _CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: widget.onBack),
          ),
          Positioned(
            top: top + 8,
            right: 12,
            child: Column(
              children: [
                if (panos.isNotEmpty)
                  _CircleBtn(
                    icon: Icons.threesixty,
                    label: '360°',
                    onTap: () => PanoramaViewerScreen.show(context, panos),
                  ),
                if (visites.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _CircleBtn(
                    icon: Icons.view_in_ar,
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: visites.first.urlAbsolue));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lien de la visite virtuelle copié : ouvrez-le dans votre navigateur')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          if (photos.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${_page + 1} / ${photos.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          if (widget.overlay != null) Positioned.fill(child: IgnorePointer(child: widget.overlay!)),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: label == null ? const CircleBorder() : const StadiumBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: label == null ? const CircleBorder() : const StadiumBorder(),
        onTap: onTap,
        child: label == null
            ? SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: AppColors.primaryBlueAnthracite))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: AppColors.primaryOcre),
                    const SizedBox(width: 4),
                    Text(label!,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite)),
                  ],
                ),
              ),
      ),
    );
  }
}
