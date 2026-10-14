import 'package:flutter_mobile_prospect_agent/core/constants/app_constants.dart';

/// Adresse absolue d'un fichier servi par le backend (« /uploads/medias/… »).
class UrlMedia {
  UrlMedia._();

  /// Lien déjà absolu conservé ; chemin relatif préfixé par l'origine du serveur.
  /// Renvoie null pour une valeur absente ou vide.
  static String? absolue(String? chemin) {
    if (chemin == null || chemin.trim().isEmpty) return null;
    final url = chemin.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = AppConstants.apiBaseUrl;
    final origine =
        base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
    return url.startsWith('/') ? '$origine$url' : '$origine/$url';
  }
}
