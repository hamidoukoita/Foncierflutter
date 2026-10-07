import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';

class BienFoncierRepository {
  final ApiClient _apiClient;

  BienFoncierRepository(this._apiClient);

  Future<List<BienFoncierModel>> getParcelles() async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/parcelles-individuelles');
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map(
              (json) => BienFoncierModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  Future<List<BienFoncierModel>> getLotsProgrammes() async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/lots-programmes');
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map(
              (json) => BienFoncierModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }
}
