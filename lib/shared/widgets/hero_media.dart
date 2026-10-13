import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/panorama_viewer_screen.dart';

/// Barre supérieure repliable des pages de détail (cité, lot) : la photo occupe le haut, puis se réduit en
/// barre de titre au défilement — le contenu ne passe jamais « sous » l'image.
/// Bouton retour à gauche ; bouton « 360° » à droite lorsqu'un panorama existe.
/// Sans photo : dégradé de marque (aucune image inventée).
class DetailSliverAppBar extends StatefulWidget {
  final String title;
  final List<MediaModel> medias;
  final bool loading;
  final VoidCallback onBack;
  final double expandedHeight;

  const DetailSliverAppBar({
    super.key,
    required this.title,
    required this.medias,
    required this.onBack,
    this.loading = false,
    this.expandedHeight = 280,
  });

  @override
  State<DetailSliverAppBar> createState() => _DetailSliverAppBarState();
}

class _DetailSliverAppBarState extends State<DetailSliverAppBar> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.medias.where((m) => m.isPhoto).toList();
    final panos = widget.medias.where((m) => m.isPanorama).toList();
    final visites = widget.medias.where((m) => m.isVisiteVirtuelle).toList();

    final top = MediaQuery.of(context).padding.top;
    final collapsedH = kToolbarHeight + top;

    return SliverAppBar(
      pinned: true,
      expandedHeight: widget.expandedHeight,
      backgroundColor: AppColors.primaryBlueAnthracite,
      foregroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        child: _CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: widget.onBack),
      ),
      actions: [
        if (visites.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CircleBtn(
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
          ),
        if (panos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CircleBtn(
              icon: Icons.threesixty,
              label: '360°',
              onTap: () => PanoramaViewerScreen.show(context, panos),
            ),
          ),
        if (panos.isEmpty && visites.isEmpty) const SizedBox(width: 12),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, c) {
          final span = (widget.expandedHeight - kToolbarHeight).clamp(1.0, 2000.0);
          final t = ((c.maxHeight - collapsedH) / span).clamp(0.0, 1.0); // 1 = déplié, 0 = replié
          return Stack(
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
                  child: Center(
                    child: widget.loading
                        ? CircularProgressIndicator(color: AppColors.white.withValues(alpha: 0.54), strokeWidth: 2)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Icon(Icons.landscape_rounded, size: 64, color: AppColors.white.withValues(alpha: 0.18)),
                          ),
                  ),
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
              // Dégradé haut pour la lisibilité des boutons.
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [AppColors.black.withValues(alpha: 0.45), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Replié : la barre devient pleine couleur, le titre apparaît.
              IgnorePointer(
                child: ColoredBox(color: AppColors.primaryBlueAnthracite.withValues(alpha: (1 - t).clamp(0.0, 1.0))),
              ),
              Positioned(
                left: 64,
                right: 120,
                top: top,
                height: kToolbarHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: (1 - t * 2.2).clamp(0.0, 1.0),
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.white),
                    ),
                  ),
                ),
              ),
              if (photos.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 38,
                  child: Opacity(
                    opacity: t,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < photos.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _page ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: i == _page ? AppColors.white : AppColors.white.withValues(alpha: 0.54),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              // « Lèvre » arrondie : le contenu se raccorde à l'image sans la recouvrir.
              Positioned(
                left: 0,
                right: 0,
                bottom: -1,
                height: 28,
                child: Opacity(
                  opacity: t,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundOffWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
    final shape = label == null ? const CircleBorder() : const StadiumBorder();
    return Center(
      child: Material(
        color: AppColors.white.withValues(alpha: 0.95),
        shape: shape,
        elevation: 1,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: label == null
              ? SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: AppColors.primaryBlueAnthracite))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 19, color: AppColors.primaryOcre),
                      const SizedBox(width: 4),
                      Text(label!,
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
