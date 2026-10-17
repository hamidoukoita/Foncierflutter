import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_reseau.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/lien_panorama_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/panorama_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Barre supérieure repliable des pages de détail (cité, lot) : la photo occupe le haut, puis se réduit en
/// barre de titre au défilement — le contenu ne passe jamais « sous » l'image.
/// Bouton retour à gauche. Les visualisations ajoutées par la société (panoramas 360°, visite virtuelle)
/// sont proposées par de grands boutons posés sur la photo, réduits en icônes dans la barre une fois repliée.
/// Sans photo : dégradé de marque (aucune image inventée).
class DetailSliverAppBar extends StatefulWidget {
  final String title;
  final List<MediaModel> medias;
  final bool loading;
  final VoidCallback onBack;
  final double expandedHeight;

  /// Points de passage entre panoramas (visite virtuelle d'une maison clé en main).
  final List<LienPanoramaModel> liensPanoramas;

  const DetailSliverAppBar({
    super.key,
    required this.title,
    required this.medias,
    required this.onBack,
    this.loading = false,
    this.expandedHeight = 280,
    this.liensPanoramas = const [],
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
        // Place réservée aux icônes de la barre repliée (dessinées dans flexibleSpace).
        SizedBox(width: 12 + (panos.isNotEmpty ? 46 : 0) + (visites.isNotEmpty ? 46 : 0)),
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
                  itemBuilder: (_, i) => ImageReseau(
                    url: photos[i].urlAbsolue,
                    attente: Container(color: AppColors.grey200),
                    secours: Container(
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
              if (panos.isNotEmpty || visites.isNotEmpty) ...[
                // Déplié : appels à l'action bien visibles sur la photo.
                Positioned(
                  right: 16,
                  bottom: 44,
                  child: IgnorePointer(
                    ignoring: t < 0.5,
                    child: Opacity(
                      opacity: t,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (visites.isNotEmpty)
                            _BoutonImmersif(
                              icone: Icons.view_in_ar_rounded,
                              titre: 'Visite virtuelle',
                              sousTitre: 'Parcourir en ligne',
                              principal: panos.isEmpty,
                              onTap: () => _ouvrirVisite(context, visites.first),
                            ),
                          if (panos.isNotEmpty && visites.isNotEmpty) const SizedBox(height: 8),
                          if (panos.isNotEmpty)
                            _BoutonImmersif(
                              icone: Icons.threesixty_rounded,
                              titre: 'Visite 360°',
                              sousTitre: panos.length > 1 ? '${panos.length} vues panoramiques' : 'Vue panoramique',
                              principal: true,
                              onTap: () => PanoramaViewerScreen.show(context, panos, liens: widget.liensPanoramas),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Replié : icônes compactes dans la barre de titre.
                Positioned(
                  right: 12,
                  top: top,
                  height: kToolbarHeight,
                  child: IgnorePointer(
                    ignoring: t >= 0.5,
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Row(
                        children: [
                          if (visites.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(right: panos.isNotEmpty ? 8 : 0),
                              child: _CircleBtn(
                                icon: Icons.view_in_ar_rounded,
                                onTap: () => _ouvrirVisite(context, visites.first),
                              ),
                            ),
                          if (panos.isNotEmpty)
                            _CircleBtn(
                              icon: Icons.threesixty,
                              onTap: () => PanoramaViewerScreen.show(context, panos, liens: widget.liensPanoramas),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: AppColors.white.withValues(alpha: 0.95),
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: AppColors.primaryBlueAnthracite)),
        ),
      ),
    );
  }
}

/// Ouvre la visite virtuelle dans le navigateur ; à défaut, copie le lien.
Future<void> _ouvrirVisite(BuildContext context, MediaModel visite) async {
  final ouvert = await launchUrl(Uri.parse(visite.urlAbsolue), mode: LaunchMode.externalApplication)
      .catchError((_) => false);
  if (ouvert) return;
  await Clipboard.setData(ClipboardData(text: visite.urlAbsolue));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d’ouvrir la visite : lien copié, collez-le dans votre navigateur')),
    );
  }
}

/// Grand bouton posé sur la photo (visite 360°, visite virtuelle).
/// [principal] : fond ocre ; sinon fond blanc, pour hiérarchiser deux boutons.
class _BoutonImmersif extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final bool principal;
  final VoidCallback onTap;

  const _BoutonImmersif({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.principal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final texte = principal ? AppColors.white : AppColors.primaryBlueAnthracite;
    return Material(
      color: principal ? AppColors.primaryOcre : AppColors.white,
      shape: const StadiumBorder(),
      elevation: 4,
      shadowColor: AppColors.black.withValues(alpha: 0.4),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 18, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 22, color: principal ? AppColors.white : AppColors.primaryOcre),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: texte)),
                  Text(sousTitre,
                      style: TextStyle(
                          fontSize: 10.5, fontWeight: FontWeight.w600, color: texte.withValues(alpha: 0.8))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
