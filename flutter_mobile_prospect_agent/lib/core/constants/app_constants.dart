class AppConstants {
  AppConstants._();

  /// Base URL API Spring Boot
  /// - Émulateur Android : 10.0.2.2
  /// - Simulateur iOS    : localhost
  /// - Téléphone réel    : IP LAN de la machine (ex. 192.168.1.20)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  static const String tokenKey = 'foncier_jwt_token';
  static const String userKey = 'foncier_user_json';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Rôles renvoyés par le backend (héritage Utilisateur)
  static const String roleAcquereur = 'ACQUEREUR';
  static const String roleAgent = 'AGENT_PROMOTEUR';
  static const String roleSociete = 'SOCIETE_PROMOTRICE';
  static const String roleAdmin = 'ADMINISTRATEUR';
}
