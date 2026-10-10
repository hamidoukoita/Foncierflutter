import 'package:dio/dio.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';

class PlanMasseRepository {
  PlanMasseRepository(this._api);
  final ApiClient _api;

  /// Plan de masse d'un programme + ses éléments (routes, espaces verts, équipements).
  /// Renvoie null si la société n'a pas encore créé de plan pour ce programme.
  Future<PlanMasse?> getByProgramme(int programmeId) async {
    int? planId;
    String? description;
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.planMasseByProgramme(programmeId));
      final parsed = ApiResponse<Map<String, dynamic>>.fromJson(
        res.data!,
        (data) => data as Map<String, dynamic>,
      );
      final data = parsed.data;
      if (!parsed.success || data == null) return null;
      planId = (data['id'] as num?)?.toInt();
      description = data['description'] as String?;
    } on DioException catch (e) {
      final inner = e.error;
      final status = inner is ApiException ? inner.statusCode : e.response?.statusCode;
      if (status == 404 || status == 400) return null;
      rethrow;
    }
    if (planId == null) return null;

    var elements = <PlanElement>[];
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.planElements(planId));
      final parsed = ApiResponse<List<dynamic>>.fromJson(
        res.data!,
        (data) => data as List<dynamic>,
      );
      elements = (parsed.data ?? [])
          .map((e) => PlanElement.fromJson(e as Map<String, dynamic>))
          .whereType<PlanElement>()
          .where((e) => e.visible)
          .toList()
        ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    } catch (_) {
      // Les lots restent affichables sans les éléments décoratifs.
    }
    return PlanMasse(id: planId, description: description, elements: elements);
  }
}
