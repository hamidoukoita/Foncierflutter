import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';

class MediaRepository {
  MediaRepository(this._api);
  final ApiClient _api;

  /// Photos, panoramas 360° et visites virtuelles d'un bien (lot ou parcelle).
  Future<List<MediaModel>> getByBien(int bienId) =>
      _fetch(ApiEndpoints.mediasByBien(bienId));

  /// Médias d'un programme (cité).
  Future<List<MediaModel>> getByProgramme(int programmeId) =>
      _fetch(ApiEndpoints.mediasByProgramme(programmeId));

  Future<List<MediaModel>> _fetch(String path) async {
    final res = await _api.get<Map<String, dynamic>>(path);
    final parsed = ApiResponse<List<dynamic>>.fromJson(
      res.data!,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success) throw Exception(parsed.message);
    final list = (parsed.data ?? [])
        .map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
        .where((m) => m.url.isNotEmpty)
        .toList();
    list.sort((a, b) => (a.ordre ?? 0).compareTo(b.ordre ?? 0));
    return list;
  }
}
