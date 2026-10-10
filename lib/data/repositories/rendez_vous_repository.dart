import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';

class RendezVousRepository {
  final ApiClient _apiClient;

  RendezVousRepository(this._apiClient);

  Future<List<RendezVousModel>> getRendezVousByAcquereur(
      int acquereurId) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>('/rendez-vous/acquereur/$acquereurId');
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map((json) => RendezVousModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  Future<List<RendezVousModel>> getRendezVous() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/rendez-vous');
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map((json) => RendezVousModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  /// Demande de visite (POST /rendez-vous). Le rendez-vous naît « EN_ATTENTE » :
  /// la société promotrice l'accepte ou le refuse ensuite.
  Future<RendezVousModel> creer({
    required int acquereurId,
    required int bienId,
    required int creneauId,
    required DateTime date,
    required String typeRDV,
    String? lieu,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.rendezVous,
      data: {
        'dateRendezVous': DateFormatter.isoLocal(date),
        'typeRDV': typeRDV,
        'statut': 'EN_ATTENTE',
        if (lieu != null && lieu.trim().isNotEmpty) 'lieu': lieu.trim(),
        'acquereurId': acquereurId,
        'bienId': bienId,
        'creneauId': creneauId,
      },
    );
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data!,
      (data) => data as Map<String, dynamic>,
    );
    if (apiResponse.success && apiResponse.data != null) {
      return RendezVousModel.fromJson(apiResponse.data!);
    }
    throw Exception(apiResponse.message);
  }
}
