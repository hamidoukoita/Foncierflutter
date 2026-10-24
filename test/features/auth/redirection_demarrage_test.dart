import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/providers/demarrage_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/redirection_demarrage.dart';

AuthUser _user(String role) => AuthUser(
    token: 't',
    id: 1,
    nom: 'Traoré',
    prenom: 'Awa',
    telephone: '70000001',
    role: role);

void main() {
  const pret = DemarrageState(pret: true);
  const pretDejaVu = DemarrageState(pret: true, onboardingVu: true);
  const deconnecte = AuthState(status: AuthStatus.unauthenticated);

  String? aller(String loc, AuthState auth, DemarrageState demarrage) =>
      redirectionDemarrage(location: loc, auth: auth, demarrage: demarrage);

  group('Démarrage', () {
    test('reste sur le splash pendant le chargement', () {
      expect(aller(AuthRoutes.splash, const AuthState(), pret), isNull);
      expect(
          aller(AuthRoutes.splash, deconnecte, const DemarrageState()), isNull);
      expect(
          aller(AuthRoutes.login, const AuthState(), pret), AuthRoutes.splash);
    });

    test("première ouverture : l'onboarding", () {
      expect(aller(AuthRoutes.splash, deconnecte, pret), AuthRoutes.onboarding);
      expect(aller(AuthRoutes.onboarding1, deconnecte, pret), isNull);
    });

    test(
        'onboarding déjà vu : la connexion, sans retour possible sur la présentation',
        () {
      expect(
          aller(AuthRoutes.splash, deconnecte, pretDejaVu), AuthRoutes.login);
      expect(aller(AuthRoutes.onboarding1, deconnecte, pretDejaVu),
          AuthRoutes.login);
      expect(aller(AuthRoutes.register, deconnecte, pretDejaVu), isNull);
    });

    test('page protégée sans session : la connexion', () {
      expect(aller('/prospect/dashboard', deconnecte, pretDejaVu),
          AuthRoutes.login);
    });

    test('connecté : le dashboard de son rôle', () {
      final acquereur =
          AuthState(status: AuthStatus.authenticated, user: _user('ACQUEREUR'));
      final agent =
          AuthState(status: AuthStatus.authenticated, user: _user('AGENT'));
      expect(aller(AuthRoutes.splash, acquereur, pret), '/prospect/dashboard');
      expect(aller(AuthRoutes.login, agent, pretDejaVu), AgentRoutes.dashboard);
      expect(aller('/prospect/cites', acquereur, pretDejaVu), isNull);
    });
  });
}
