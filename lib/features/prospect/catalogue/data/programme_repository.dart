import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';

class ProgrammeRepository {
  ProgrammeRepository(this._api);
  final ApiClient _api;

  Future<List<ProgrammeFoncier>> getAll() async {
    final res = await _api.get(ApiEndpoints.programmes);
    final body = res.data as Map<String, dynamic>;
    final parsed = ApiResponse.fromJson(
      body,
      (data) => (data as List<dynamic>)
          .map((e) => ProgrammeFoncier.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success) throw Exception(parsed.message);
    return parsed.data ?? [];
  }

  Future<ProgrammeFoncier> getById(int id) async {
    final res = await _api.get(ApiEndpoints.programmeById(id));
    final body = res.data as Map<String, dynamic>;
    final parsed = ApiResponse.fromJson(
      body,
      (data) => ProgrammeFoncier.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message.isEmpty ? 'Programme introuvable' : parsed.message);
    }
    return parsed.data!;
  }
}
