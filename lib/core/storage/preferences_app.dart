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
}
