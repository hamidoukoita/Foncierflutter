import 'package:shared_preferences/shared_preferences.dart';

/// Préférences locales non sensibles de l'application (hors session JWT).
class PreferencesApp {
  static const String _cleOnboardingVu = 'foncier_onboarding_vu';

  Future<bool> onboardingVu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cleOnboardingVu) ?? false;
  }

  Future<void> marquerOnboardingVu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cleOnboardingVu, true);
  }

  /// Plus grand identifiant de notification déjà signalé sur le téléphone (null au premier lancement).
  Future<int?> derniereNotificationSignalee(int utilisateurId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('foncier_notification_signalee_$utilisateurId');
  }

  Future<void> memoriserNotificationSignalee(int utilisateurId, int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('foncier_notification_signalee_$utilisateurId', notificationId);
  }
}
