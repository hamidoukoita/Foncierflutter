/// Miroir de ApiResponse<T> côté Spring Boot.
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null || fromData == null
          ? null
          : fromData(json['data']),
    );
  }
}

/// Utilisateur connecté (AuthResponse backend).
class AuthUser {
  final String token;
  final String type;
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String role;
  final String? statut;
  final int? societeId;
  final String? societeNom;
  final bool? estResponsableSociete;
  final String? fonctionLibelle;
  final List<String> permissions;

  const AuthUser({
    required this.token,
    this.type = 'Bearer',
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    this.statut,
    this.societeId,
    this.societeNom,
    this.estResponsableSociete,
    this.fonctionLibelle,
    this.permissions = const [],
  });

  String get fullName => '$prenom $nom'.trim();

  bool get isAcquereur =>
      role.toUpperCase().contains('ACQUEREUR') ||
      role.toUpperCase().contains('PROSPECT');

  bool get isAgent =>
      role.toUpperCase().contains('AGENT');

  bool get isSociete =>
      role.toUpperCase().contains('SOCIETE');

  bool get isAdmin =>
      role.toUpperCase().contains('ADMIN');

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      token: json['token'] as String? ?? '',
      type: json['type'] as String? ?? 'Bearer',
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      statut: json['statut'] as String?,
      societeId: (json['societeId'] as num?)?.toInt(),
      societeNom: json['societeNom'] as String?,
      estResponsableSociete: json['estResponsableSociete'] as bool?,
      fonctionLibelle: json['fonctionLibelle'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'type': type,
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'role': role,
        'statut': statut,
        'societeId': societeId,
        'societeNom': societeNom,
        'estResponsableSociete': estResponsableSociete,
        'fonctionLibelle': fonctionLibelle,
        'permissions': permissions,
      };
}

class LoginRequest {
  final String telephone;
  final String motDePasse;

  LoginRequest({required this.telephone, required this.motDePasse});

  Map<String, dynamic> toJson() => {
        'telephone': telephone,
        'motDePasse': motDePasse,
      };
}

class RegisterAcquereurRequest {
  final String nom;
  final String prenom;
  final String telephone;
  final String motDePasse;
  final String? paysResidence;
  final String? preference;

  RegisterAcquereurRequest({
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.motDePasse,
    this.paysResidence,
    this.preference,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'motDePasse': motDePasse,
        if (paysResidence != null) 'paysResidence': paysResidence,
        if (preference != null) 'preference': preference,
      };
}
