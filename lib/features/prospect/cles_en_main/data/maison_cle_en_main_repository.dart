import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import '../domain/maison_cle_en_main.dart';

class MaisonCleEnMainRepository {
  final ApiClient _api;
  MaisonCleEnMainRepository(this._api);

  /// Catalogue public : maisons des sociétés agréées.
  Future<List<MaisonCleEnMain>> catalogue() async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.maisonsCleEnMain);
    return _liste(res.data!);
  }

  Future<List<MaisonCleEnMain>> deSociete(int societeId) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.maisonsDeSociete(societeId));
    return _liste(res.data!);
  }

  Future<MaisonCleEnMain> detail(int id) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.maisonById(id));
    final r = ApiResponse<Map<String, dynamic>>.fromJson(res.data!, (d) => d as Map<String, dynamic>);
    if (!r.success || r.data == null) throw Exception(r.message);
    return MaisonCleEnMain.fromJson(r.data!);
  }

  List<MaisonCleEnMain> _liste(Map<String, dynamic> body) {
    final r = ApiResponse<List<dynamic>>.fromJson(body, (d) => d as List<dynamic>);
    if (!r.success || r.data == null) throw Exception(r.message);
    return r.data!.map((j) => MaisonCleEnMain.fromJson(j as Map<String, dynamic>)).toList();
  }
}
