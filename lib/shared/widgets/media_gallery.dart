import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_reseau.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/panorama_viewer_screen.dart';

/// Galerie d'un bien : carrousel de photos + liste des panoramas 360°.
/// N'affiche rien tant qu'aucun média n'existe (ou si le chargement échoue).
class MediaGallery extends ConsumerWidget {
  final int bienId;

  const MediaGallery({super.key, required this.bienId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mediasBienProvider(bienId));

    return async.when(
      loading: () => Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: AppRadius.radiusLg,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOcre, strokeWidth: 2.5),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (medias) {
        if (medias.isEmpty) return const SizedBox.shrink();
        final photos = medias.where((m) => m.isPhoto).toList();
        final autres = medias.where((m) => !m.isPhoto).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photos.isNotEmpty) _PhotoCarousel(photos: photos),
            if (autres.isNotEmpty) ...[
              if (photos.isNotEmpty) const SizedBox(height: 12),
              for (final m in autres) _VisiteTile(media: m),
            ],
          ],
        );
      },
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  final List<MediaModel> photos;
  const _PhotoCarousel({required this.photos});

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusLg,
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: double.infinity,
                  child: ImageReseau(
                    url: widget.photos[i].urlAbsolue,
                    attente: Container(
                      color: AppColors.backgroundOffWhite,
                      child: const Center(
                        child: Icon(Icons.landscape_rounded, color: AppColors.successGreen, size: 36),
                      ),
                    ),
                    secours: Container(
                      color: AppColors.backgroundOffWhite,
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.grey400, size: 36),
                    ),
                  ),
                );
              },
            ),
            if (widget.photos.length > 1)
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.photos.length}',
                    style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VisiteTile extends StatelessWidget {
  final MediaModel media;
  const _VisiteTile({required this.media});

  @override
  Widget build(BuildContext context) {
    final label = media.isPanorama ? 'Vue panoramique 360°' : 'Visite virtuelle';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOcre.withValues(alpha: 0.12),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(
              media.isPanorama ? Icons.threesixty : Icons.view_in_ar,
              color: AppColors.primaryOcre,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.titre?.isNotEmpty == true ? media.titre! : label,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: media.isPanorama
                ? () => PanoramaViewerScreen.show(context, [media])
                : () async {
                    await Clipboard.setData(ClipboardData(text: media.urlAbsolue));
                    if (context.mounted) {
                      AppSnackbar.success(context, 'Lien copié : ouvrez-le dans votre navigateur');
                    }
                  },
            icon: Icon(media.isPanorama ? Icons.threesixty : Icons.link_rounded, size: 18, color: AppColors.primaryOcre),
            label: Text(media.isPanorama ? 'Ouvrir' : 'Copier le lien', style: TextStyle(color: AppColors.primaryOcre, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
