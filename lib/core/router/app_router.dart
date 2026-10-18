import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/ombordin1_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/ombording2_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/ombordingMain_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/onbording3_screnn.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/login_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/register_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/splash_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/mot_de_passe_oublie_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/providers/demarrage_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/redirection_demarrage.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/views/programme_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/views/lots_list_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/presentation/screens/plan_masse_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/localisation_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/localisation/presentation/screens/localisation_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/views/lot_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/construction_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/cles_en_main_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/domain/maison_cle_en_main.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/presentation/screens/cles_en_main_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/cles_en_main/presentation/screens/maison_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/presentation/screens/mes_projets_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/presentation/screens/projet_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/presentation/screens/soumettre_projet_screen.dart';

import 'package:flutter_mobile_prospect_agent/features/prospect/shell/prospect_shell.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shell/agent_shell.dart';

import 'package:flutter_mobile_prospect_agent/features/agent/dashboard/presentation/views/agent_dashboard_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/reservations/presentation/views/agent_reservations_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/reservations/presentation/views/reservation_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/visites/presentation/views/agent_visites_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/visites/presentation/views/visite_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_dashboard_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_cites_plan_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_reservations_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_parcelles_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_parcelle_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_mes_visites_screen.dart';

/// Notifier pour forcer le refresh du router quand l'auth ou le démarrage change.
class _AuthRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final _authRefreshProvider = Provider<_AuthRefresh>((ref) {
  final r = _AuthRefresh();
  ref.listen(authProvider, (_, __) => r.refresh());
  ref.listen(demarrageProvider, (_, __) => r.refresh());
  return r;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_authRefreshProvider);

  return GoRouter(
    initialLocation: AuthRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectionDemarrage(
      location: state.matchedLocation,
      auth: ref.read(authProvider),
      demarrage: ref.read(demarrageProvider),
    ),
    routes: [
      GoRoute(
          path: AuthRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: AuthRoutes.onboarding,
          builder: (_, __) => const OnboardingPage()),
      GoRoute(
          path: AuthRoutes.onboarding1,
          builder: (_, __) => const OnboardingOnePage()),
      GoRoute(
          path: AuthRoutes.onboarding2,
          builder: (_, __) => const OnboardingTwoPage()),
      GoRoute(
          path: AuthRoutes.onboarding3,
          builder: (_, __) => const OnboardingThreePage()),
      GoRoute(path: AuthRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: AuthRoutes.register,
          builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: AuthRoutes.motDePasseOublie,
          builder: (_, __) => const MotDePasseOublieScreen()),
      GoRoute(
        path: '/prospect/programmes/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProgrammeDetailScreen(programmeId: id);
        },
      ),
      GoRoute(
        path: LocalisationRoutes.programmePattern,
        builder: (context, state) => LocalisationScreen.programme(
          programmeId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: LocalisationRoutes.bienPattern,
        builder: (context, state) => LocalisationScreen.bien(
          bienId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/prospect/programmes/:id/plan',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final lot = int.tryParse(state.uri.queryParameters['lot'] ?? '');
          return PlanMasseScreen(programmeId: id, initialLotId: lot);
        },
      ),
      GoRoute(
        path: '/prospect/programmes/:id/lots',
        builder: (context, state) =>
            LotsListScreen(programmeId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/prospect/parcelles/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProspectParcelleDetailScreen(parcelleId: id);
        },
      ),
      GoRoute(
        path: '/prospect/lots/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return LotDetailScreen(lotId: id);
        },
      ),
      // « Construire sur mon terrain » : « nouveau » avant « :id ».
      GoRoute(
        path: ClesEnMainRoutes.detailPattern,
        builder: (context, state) => MaisonDetailScreen(
            maisonId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: ConstructionRoutes.nouveau,
        // extra : maison clé en main d'où vient l'acquéreur (« construire une maison comme celle-ci »).
        builder: (context, state) => SoumettreProjetScreen(
            maisonDeReference: state.extra is MaisonCleEnMain
                ? state.extra as MaisonCleEnMain
                : null),
      ),
      GoRoute(
        path: ConstructionRoutes.detailPattern,
        builder: (context, state) => ProjetDetailScreen(
            projetId: int.parse(state.pathParameters['id']!)),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ProspectShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prospect/dashboard',
                builder: (context, state) => const ProspectDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prospect/cites',
                builder: (context, state) {
                  final zone = state.uri.queryParameters['zone'];
                  return ProspectCitesPlanScreen(
                      key: ValueKey(zone), zone: zone);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prospect/parcelles',
                builder: (context, state) => const ProspectParcellesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ClesEnMainRoutes.liste,
                builder: (context, state) => const ClesEnMainScreen(),
              ),
            ],
          ),
          // Rangée « Mes dossiers » (bouton + de la barre).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ConstructionRoutes.liste,
                builder: (context, state) => const MesProjetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prospect/reservations',
                builder: (context, state) => const ProspectReservationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prospect/visites',
                builder: (context, state) => const ProspectMesVisitesScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AgentShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AgentRoutes.dashboard,
                builder: (context, state) => const AgentDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AgentRoutes.visites,
                builder: (context, state) => const AgentVisitesScreen(),
              ),
            ],
          ),
        ],
      ),
      // Pages agent plein écran (hors barre de navigation)
      GoRoute(
        path: AgentRoutes.visiteDetailPattern,
        builder: (context, state) => VisiteDetailScreen(
          visiteId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AgentRoutes.reservationDetailPattern,
        builder: (context, state) => ReservationDetailScreen(
          reservationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AgentRoutes.reservations,
        builder: (context, state) => const AgentReservationsScreen(),
      ),
    ],
  );
});
