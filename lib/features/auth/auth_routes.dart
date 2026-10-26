/// Chemins publics : démarrage, onboarding et authentification.
class AuthRoutes {
  AuthRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/ombordingMain';

  /// Pages de présentation (défilement horizontal).
  static const String onboarding1 = '/ombording1';
  static const String login = '/login';
  static const String register = '/register';
  static const String motDePasseOublie = '/mot-de-passe-oublie';

  /// Pages de présentation, montrées seulement à la première ouverture.
  static const Set<String> pagesOnboarding = {
    onboarding,
    onboarding1,
  };

  /// Pages accessibles sans être connecté.
  static const Set<String> pagesPubliques = {
    splash,
    ...pagesOnboarding,
    login,
    register,
    motDePasseOublie,
  };
}
