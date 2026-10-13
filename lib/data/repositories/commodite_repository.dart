import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/models/proximite_commodite_model.dart';

class CommoditeRepository {
  final ApiClient _apiClient;

  CommoditeRepository(this._apiClient);

  /// Commodités rattachées à une cité (héritées par ses lots).
  Future<List<ProximiteCommoditeModel>> getProximitesProgramme(
          int programmeId) =>
      _getProximites(ApiEndpoints.proximitesByProgramme(programmeId));

  /// Commodités rattachées directement à un bien (parcelle individuelle).
  Future<List<ProximiteCommoditeModel>> getProximitesBien(int bienId) =>
      _getProximites(ApiEndpoints.proximitesByBien(bienId));

  Future<List<ProximiteCommoditeModel>> _getProximites(String path) async {
    final response = await _apiClient.get<Map<String, dynamic>>(path);
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );
    if (apiResponse.success && apiResponse.data != null) {
      return ProximiteCommoditeModel.listFromJson(apiResponse.data);
    }
    throw Exception(apiResponse.message);
  }
}
