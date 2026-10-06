import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/core/storage/token_storage.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/repositories/auth_repository.dart';

// ---------- DI de base (partagé toute l'app) ----------

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

// ---------- État auth ----------

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final bool loading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
    bool? loading,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      loading: loading ?? this.loading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(restore);
    return const AuthState();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> restore() async {
    state = state.copyWith(loading: true, clearError: true);
    final user = await _repo.restoreSession();
    if (user != null && user.token.isNotEmpty) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String telephone, String motDePasse) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.login(
        LoginRequest(telephone: telephone.trim(), motDePasse: motDePasse),
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('ApiException: ', ''),
      );
      return false;
    }
  }

  Future<bool> registerAcquereur({
    required String nom,
    required String prenom,
    required String telephone,
    required String motDePasse,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.registerAcquereur(
        RegisterAcquereurRequest(
          nom: nom.trim(),
          prenom: prenom.trim(),
          telephone: telephone.trim(),
          motDePasse: motDePasse,
        ),
      );
      // Compte souvent EN_ATTENTE : on ne force pas la session si token absent
      if (user.token.isNotEmpty) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('ApiException: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
