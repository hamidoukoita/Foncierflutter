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

  Future<AuthUser?> restoreSession() => _storage.readUser();

  Future<void> logout() => _storage.clear();
}
