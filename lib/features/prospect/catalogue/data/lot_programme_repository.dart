import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';

class LotProgrammeRepository {
  LotProgrammeRepository(this._api);
  final ApiClient _api;

  Future<List<LotProgramme>> getByProgramme(int programmeId) async {
    final res = await _api.get(ApiEndpoints.lotsByProgramme(programmeId));
    final body = res.data as Map<String, dynamic>;
    final parsed = ApiResponse.fromJson(
      body,
      (data) => (data as List<dynamic>)
          .map((e) => LotProgramme.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success) throw Exception(parsed.message);
    return parsed.data ?? [];
  }

  Future<LotProgramme> getById(int id) async {
    final res = await _api.get('${ApiEndpoints.lotsProgrammes}/$id');
    final body = res.data as Map<String, dynamic>;
    final parsed = ApiResponse.fromJson(
      body,
      (data) => LotProgramme.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message.isEmpty ? 'Lot introuvable' : parsed.message);
    }
    return parsed.data!;
  }
}
