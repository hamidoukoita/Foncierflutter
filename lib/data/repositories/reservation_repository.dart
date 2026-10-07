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

  Future<List<ReservationModel>> getReservationsByAgent() async {
    // Supposons qu'il y a un endpoint pour l'agent, sinon on filtre côté client
    // Le patch Backend devrait avoir ajouté ce endpoint, ou on utilise getAll()
    // Pour l'instant on simule avec getAll (ou on utilise le paramètre de l'agent si dispo)
    final response =
        await _apiClient.get<Map<String, dynamic>>('/reservations');
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
