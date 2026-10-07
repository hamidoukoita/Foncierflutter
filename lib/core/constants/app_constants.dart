import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  /// Base URL API Spring Boot
  /// - Émulateur Android : 10.0.2.2
  /// - Web / Desktop / iOS : 127.0.0.1 ou localhost
  /// - Téléphone réel    : IP LAN de la machine (ex. 192.168.1.20)
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }

    return 'http://127.0.0.1:8080/api';
  }

  static const String tokenKey = 'foncier_jwt_token';
  static const String userKey = 'foncier_user_json';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Rôles renvoyés par le backend
  static const String roleAcquereur = 'ACQUEREUR';
  static const String roleAgent = 'AGENT';
  static const String roleAdmin = 'ADMIN';
}
