import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/models/creneau_model.dart';

class CreneauRepository {
  CreneauRepository(this._api);
  final ApiClient _api;

  /// Créneaux disponibles d'une société promotrice (GET /creneaux?societeId=&disponible=true).
  Future<List<CreneauModel>> getDisponibles(int societeId) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.creneaux,
      queryParameters: {'societeId': societeId, 'disponible': true},
    );
    final parsed = ApiResponse<List<dynamic>>.fromJson(
      res.data!,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success) throw Exception(parsed.message);
    return (parsed.data ?? [])
        .map((e) => CreneauModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
