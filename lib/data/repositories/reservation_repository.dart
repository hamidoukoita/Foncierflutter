import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';

class ReservationRepository {
  final ApiClient _apiClient;

  ReservationRepository(this._apiClient);

  Future<List<ReservationModel>> getReservationsByAcquereur(
      int acquereurId) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>('/reservations/acquereur/$acquereurId');
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map(
              (json) => ReservationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  /// Réservations sous le suivi d'un agent collaborateur.
  Future<List<ReservationModel>> getReservationsByAgent(int agentId) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>(ApiEndpoints.reservationsByAgent(agentId));
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map(
              (json) => ReservationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  Future<ReservationModel> reserverBien(int bienId, int acquereurId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reservations',
      data: {
        'bienId': bienId,
        'acquereurId': acquereurId,
        'dateReservation': DateTime.now().toIso8601String(),
      },
    );
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return ReservationModel.fromJson(apiResponse.data!);
    }
    throw Exception(apiResponse.message);
  }
}
