import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/models/lien_panorama_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';

class MediaRepository {
  MediaRepository(this._api);
  final ApiClient _api;

  /// Photos et panoramas 360° d'un bien (lot ou parcelle).
  Future<List<MediaModel>> getByBien(int bienId) =>
      _fetch(ApiEndpoints.mediasByBien(bienId));

  /// Médias d'un modèle de maison du catalogue de construction.
  Future<List<MediaModel>> getByModele(int modeleId) =>
      _fetch(ApiEndpoints.mediasByModele(modeleId));

  /// Points de passage entre les panoramas d'un bien (visite virtuelle d'une maison clé en main).
  Future<List<LienPanoramaModel>> getLiensByBien(int bienId) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.liensPanoramasByBien(bienId));
    final parsed = ApiResponse<List<dynamic>>.fromJson(res.data!, (data) => data as List<dynamic>);
    if (!parsed.success) throw Exception(parsed.message);
    return (parsed.data ?? []).map((e) => LienPanoramaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

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
