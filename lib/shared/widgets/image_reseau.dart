import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Image distante (couverture, photo, logo) avec un visuel d'attente et de secours.
/// Sur téléphone : cache disque via cached_network_image. Sur le web : Image.network, qui
/// s'appuie sur le cache d'images de Flutter — cached_network_image peut y laisser une image
/// déjà chargée bloquée sur son visuel d'attente au retour sur l'écran.
class ImageReseau extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Widget attente;
  final Widget secours;

  const ImageReseau({
    super.key,
    required this.url,
    required this.attente,
    Widget? secours,
    this.fit = BoxFit.cover,
  }) : secours = secours ?? attente;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, __) => attente,
        errorWidget: (_, __, ___) => secours,
      );
    }
    return Image.network(
      url,
      fit: fit,
      // Garde l'image affichée pendant une reconstruction au lieu de repasser par l'attente.
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, synchrone) =>
          synchrone || frame != null ? child : attente,
      errorBuilder: (_, __, ___) => secours,
    );
  }
}
