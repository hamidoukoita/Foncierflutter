import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/providers/demarrage_provider.dart';

/// Dashboard correspondant au rôle de l'utilisateur connecté.
String dashboardDe(AuthUser? user) =>
    user?.isAgent == true || user?.isSociete == true
        ? AgentRoutes.dashboard
        : '/prospect/dashboard';

/// Où envoyer l'utilisateur qui arrive sur [location] (null : il y reste).
///
/// - splash tant que la session et les préférences se chargent ;
/// - connecté : son dashboard, jamais les pages publiques ;
/// - non connecté : l'onboarding à la première ouverture seulement, sinon la connexion.
String? redirectionDemarrage({
  required String location,
  required AuthState auth,
  required DemarrageState demarrage,
}) {
  if (auth.status == AuthStatus.unknown || !demarrage.pret) {
    return location == AuthRoutes.splash ? null : AuthRoutes.splash;
  }

  final publique = AuthRoutes.pagesPubliques.contains(location);
  if (auth.status == AuthStatus.authenticated) {
    return publique ? dashboardDe(auth.user) : null;
  }

  final accueil =
      demarrage.onboardingVu ? AuthRoutes.login : AuthRoutes.onboarding;
  if (location == AuthRoutes.splash || !publique) return accueil;
  final pageOnboarding = AuthRoutes.pagesOnboarding.contains(location);
  return demarrage.onboardingVu && pageOnboarding ? AuthRoutes.login : null;
}
