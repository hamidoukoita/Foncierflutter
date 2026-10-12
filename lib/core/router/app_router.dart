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
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/views/programme_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/views/lots_list_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/presentation/screens/plan_masse_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/views/lot_detail_screen.dart';

import 'package:flutter_mobile_prospect_agent/features/prospect/shell/prospect_shell.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shell/agent_shell.dart';

import 'package:flutter_mobile_prospect_agent/features/agent/dashboard/presentation/views/agent_dashboard_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/reservations/presentation/views/agent_reservations_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/visites/presentation/views/agent_visites_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/visites/presentation/views/visite_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_dashboard_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_cites_plan_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_reservations_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_parcelles_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_parcelle_detail_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_mes_visites_screen.dart';

/// Notifier pour forcer le refresh du router quand l'auth change.
class _AuthRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final _authRefreshProvider = Provider<_AuthRefresh>((ref) {
  final r = _AuthRefresh();
  ref.listen(authProvider, (_, __) => r.refresh());
  return r;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_authRefreshProvider);

  return GoRouter(
    initialLocation: '/ombordingMain',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (auth.status == AuthStatus.unknown) {
        return null; // splash / attente restore
      }

      final loggingIn = loc == '/login' ||
          loc == '/register' ||
          loc == '/ombordingMain' ||
          loc == '/ombording1' ||
          loc == '/ombording2' ||
          loc == '/ombording3';
      final isAuth = auth.status == AuthStatus.authenticated;

      if (!isAuth && !loggingIn) return '/ombording1';
      if (isAuth && loggingIn) {
        final user = auth.user;

        if (user?.isAgent == true || user?.isSociete == true){

          return AgentRoutes.dashboard;
        }

        return '/prospect/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
          path: '/ombordingMain', builder: (_, __) => const OnboardingPage()),
      GoRoute(
          path: '/ombording1', builder: (_, __) => const OnboardingOnePage()),
      GoRoute(
          path: '/ombording2', builder: (_, __) => const OnboardingTwoPage()),
      GoRoute(
          path: '/ombording3', builder: (_, __) => const OnboardingThreePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/prospect/programmes/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProgrammeDetailScreen(programmeId: id);
        },
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
                builder: (context, state) => const ProspectCitesPlanScreen(),
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
                path: '/prospect/parcelles',
                builder: (context, state) => const ProspectParcellesScreen(),
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
        path: AgentRoutes.reservations,
        builder: (context, state) => const AgentReservationsScreen(),
      ),
    ],
  );
});
