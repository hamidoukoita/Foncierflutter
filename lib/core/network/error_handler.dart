import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ErrorHandler {
  ErrorHandler._();

  static ApiException fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String message = 'Une erreur est survenue.';

    if (data is Map) {
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        message = data['message'] as String;
      } else if (data['error'] is String) {
        message = data['error'] as String;
      }
      // Validation Spring
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final parts = (data['errors'] as List)
            .map((e) {
              if (e is Map) {
                return e['defaultMessage']?.toString() ?? e['message']?.toString();
              }
              return e?.toString();
            })
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) message = parts.join(' · ');
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Délai dépassé. Vérifiez votre connexion ou l’URL du serveur.';
        break;
      case DioExceptionType.connectionError:
        message =
            'Impossible de joindre le serveur. Vérifiez que le backend tourne et l’URL (${e.requestOptions.baseUrl}).';
        break;
      case DioExceptionType.badResponse:
        if (status == 401) message = message.isEmpty ? 'Identifiants incorrects ou session expirée.' : message;
        if (status == 403) message = message.isEmpty ? 'Accès refusé.' : message;
        break;
      default:
        break;
    }

    return ApiException(message, statusCode: status);
  }
}
