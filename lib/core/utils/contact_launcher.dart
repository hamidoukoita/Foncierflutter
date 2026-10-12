import 'package:url_launcher/url_launcher.dart';

/// Ouverture des applications de contact natives (téléphone).
class ContactLauncher {
  ContactLauncher._();

  /// Ouvre le composeur ; retourne `false` si l'appel est impossible.
  static Future<bool> appeler(String? telephone) async {
    if (telephone == null || telephone.trim().isEmpty) return false;
    final uri = Uri(scheme: 'tel', path: telephone.replaceAll(' ', ''));
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}
