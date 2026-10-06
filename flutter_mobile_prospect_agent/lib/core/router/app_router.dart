import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/login_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/register_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/views/role_selection_screen.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/shell/prospect_shell.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shell/agent_shell.dart';

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
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (auth.status == AuthStatus.unknown) {
        return null; // splash / attente restore
      }

      final loggingIn = loc == '/login' || loc == '/register' || loc == '/';
      final isAuth = auth.status == AuthStatus.authenticated;

      if (!isAuth && !loggingIn) return '/login';
      if (isAuth && loggingIn) {
        final user = auth.user;
        if (user?.isAgent == true || user?.isSociete == true) return '/agent';
        return '/prospect';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/prospect', builder: (_, __) => const ProspectShell()),
      GoRoute(path: '/agent', builder: (_, __) => const AgentShell()),
    ],
  );
});
