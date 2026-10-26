import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<NotificationModel>> getByUtilisateur(int utilisateurId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.notificationsByUtilisateur(utilisateurId));
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map((json) =>
              NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  Future<void> marquerLue(int id) async {
    await _apiClient.patch<Map<String, dynamic>>(ApiEndpoints.lireNotification(id));
  }

  Future<void> toutMarquerLu(int utilisateurId) async {
    await _apiClient.patch<Map<String, dynamic>>(ApiEndpoints.toutLireNotifications(utilisateurId));
  }

  /// Marque lues les notifications de l'utilisateur connecté qui concernent cet élément.
  Future<void> marquerLuesPourCible(String cibleType, int cibleId) async {
    await _apiClient.patch<Map<String, dynamic>>(ApiEndpoints.lireNotificationsCible(cibleType, cibleId));
  }
}
