import 'package:dio/dio.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/storage/token_storage.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final TokenStorage _storage;

  Future<AuthUser> login(LoginRequest request) async {
    try {
      final res = await _api.post(ApiEndpoints.login, data: request.toJson());
      final body = res.data as Map<String, dynamic>;
      final parsed = ApiResponse.fromJson(
        body,
        (data) => AuthUser.fromJson(data as Map<String, dynamic>),
      );
      if (!parsed.success || parsed.data == null) {
        throw ApiException(
            parsed.message.isEmpty ? 'Connexion impossible.' : parsed.message);
      }
      final user = parsed.data!;
      if (user.token.isEmpty) {
        throw ApiException('Token JWT manquant dans la réponse.');
      }
      await _storage.saveSession(user);
      return user;
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) rethrow;
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<AuthUser> registerAcquereur(RegisterAcquereurRequest request) async {
    try {
      final res = await _api.post(ApiEndpoints.registerAcquereur,
          data: request.toJson());
      final body = res.data as Map<String, dynamic>;
      final parsed = ApiResponse.fromJson(
        body,
        (data) => AuthUser.fromJson(data as Map<String, dynamic>),
      );
      if (!parsed.success || parsed.data == null) {
        throw ApiException(parsed.message.isEmpty
            ? 'Inscription impossible.'
            : parsed.message);
      }
      final user = parsed.data!;
      if (user.token.isNotEmpty) {
        await _storage.saveSession(user);
      }
      return user;
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) rethrow;
      throw ErrorHandler.fromDio(e);
    }
  }

  /// Met à jour le nom et le prénom de l'acquéreur, puis la session locale.
  Future<AuthUser> modifierIdentite(AuthUser user, {required String nom, required String prenom}) async {
    try {
      final res = await _api.patch(
        ApiEndpoints.identiteAcquereur(user.id),
        data: {'nom': nom, 'prenom': prenom},
      );
      final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) => data);
      if (!parsed.success) {
        throw ApiException(parsed.message.isEmpty ? 'Mise à jour impossible.' : parsed.message);
      }
      final misAJour = user.copyWith(nom: nom, prenom: prenom);
      await _storage.saveSession(misAJour);
      return misAJour;
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      throw ErrorHandler.fromDio(e);
    }
  }

  /// Change le numéro de connexion (confirmé par le mot de passe) ; le serveur renvoie une nouvelle
  /// session, l'ancien jeton portant l'ancien numéro.
  Future<AuthUser> changerTelephone({required String nouveauTelephone, required String motDePasse}) async {
    final data = await _envoyer(() => _api.patch(ApiEndpoints.monTelephone,
        data: {'nouveauTelephone': nouveauTelephone, 'motDePasse': motDePasse}));
    final user = AuthUser.fromJson(data as Map<String, dynamic>);
    await _storage.saveSession(user);
    return user;
  }

  Future<void> changerMotDePasse({required String ancien, required String nouveau}) => _envoyer(() => _api.patch(
      ApiEndpoints.monMotDePasse,
      data: {'ancienMotDePasse': ancien, 'nouveauMotDePasse': nouveau}));

  /// Mot de passe oublié : le code « envoyé par SMS » est simulé et renvoyé par le serveur.
  Future<({String code, int validiteMinutes})> demanderCode(String telephone) async {
    final data = await _envoyer(() => _api.post(ApiEndpoints.motDePasseOublie, data: {'telephone': telephone}));
    final json = data as Map<String, dynamic>;
    return (code: json['code'] as String, validiteMinutes: (json['validiteMinutes'] as num?)?.toInt() ?? 10);
  }

  Future<void> reinitialiserMotDePasse({required String telephone, required String code, required String nouveau}) =>
      _envoyer(() => _api.post(ApiEndpoints.motDePasseOublieConfirmer,
          data: {'telephone': telephone, 'code': code, 'nouveauMotDePasse': nouveau}));

  /// Appel d'API générique : renvoie `data`, ou lève une ApiException avec le message du serveur.
  Future<Object?> _envoyer(Future<Response<dynamic>> Function() appel) async {
    try {
      final res = await appel();
      final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) => data);
      if (!parsed.success) {
        throw ApiException(parsed.message.isEmpty ? 'Opération impossible.' : parsed.message);
      }
      return parsed.data;
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<AuthUser?> restoreSession() => _storage.readUser();

  Future<void> logout() => _storage.clear();
}
