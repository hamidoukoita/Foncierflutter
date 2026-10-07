import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/login_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/register_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/shell/prospect_shell.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shell/agent_shell.dart';

import 'package:flutter_mobile_prospect_agent/features/agent/presentation/screens/agent_dashboard_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/presentation/screens/agent_visites_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_dashboard_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_cites_plan_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_reservations_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/screens/prospect_parcelles_screen.dart';
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
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (auth.status == AuthStatus.unknown) {
        return null; // splash / attente restore
      }

      final loggingIn = loc == '/login' || loc == '/register';
      final isAuth = auth.status == AuthStatus.authenticated;

      if (!isAuth && !loggingIn) return '/login';
      if (isAuth && loggingIn) {
        final user = auth.user;
        if (user?.isAgent == true || user?.isSociete == true)
          return '/agent/dashboard';
        return '/prospect/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
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
                path: '/agent/dashboard',
                builder: (context, state) => const AgentDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agent/visites',
                builder: (context, state) => const AgentVisitesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
