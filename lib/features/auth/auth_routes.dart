/// Chemins publics : démarrage, onboarding et authentification.
class AuthRoutes {
  AuthRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/ombordingMain';
  static const String onboarding1 = '/ombording1';
  static const String onboarding2 = '/ombording2';
  static const String onboarding3 = '/ombording3';
  static const String login = '/login';
  static const String register = '/register';

  /// Pages de présentation, montrées seulement à la première ouverture.
  static const Set<String> pagesOnboarding = {
    onboarding,
    onboarding1,
    onboarding2,
    onboarding3
  };

  /// Pages accessibles sans être connecté.
  static const Set<String> pagesPubliques = {
    splash,
    ...pagesOnboarding,
    login,
    register
  };
}
