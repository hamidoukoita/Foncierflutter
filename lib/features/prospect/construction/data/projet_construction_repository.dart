import 'package:dio/dio.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import '../domain/modele_maison.dart';
import '../domain/projet_construction.dart';
import '../domain/societe_promotrice.dart';
import '../domain/soumission_projet.dart';

/// Accès API du parcours « Construire sur mon terrain ».
class ProjetConstructionRepository {
  final ApiClient _api;
  ProjetConstructionRepository(this._api);

  /// Sociétés dont l'agrément a été vérifié : seules destinataires possibles d'un projet.
  Future<List<SocietePromotrice>> societesAgreees() async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.societes,
        queryParameters: {'statut': 'VERIFIER'});
    return _liste(res.data!).map(SocietePromotrice.fromJson).toList();
  }

  Future<List<ModeleMaison>> modelesDeSociete(int societeId) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.modelesMaison,
        queryParameters: {'societeId': societeId});
    return _liste(res.data!).map(ModeleMaison.fromJson).toList();
  }

  Future<List<ProjetConstruction>> mesProjets(int acquereurId) async {
    final res = await _api
        .get<Map<String, dynamic>>(ApiEndpoints.projetsByAcquereur(acquereurId));
    final projets = _liste(res.data!).map(ProjetConstruction.fromJson).toList();
    projets.sort((a, b) => (b.dateDemande ?? DateTime(0)).compareTo(a.dateDemande ?? DateTime(0)));
    return projets;
  }

  Future<ProjetConstruction> projet(int id) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.projetById(id));
    return ProjetConstruction.fromJson(_objet(res.data!));
  }

  Future<ProjetConstruction> soumettre(SoumissionProjet soumission) async {
    final res = await _api.post<Map<String, dynamic>>(ApiEndpoints.projetsConstruction,
        data: soumission.toJson());
    return ProjetConstruction.fromJson(_objet(res.data!));
  }

  Future<void> joindre(int projetId, PieceAJoindre piece) async {
    final f = piece.fichier;
    final contenu = f.path != null
        ? await MultipartFile.fromFile(f.path!, filename: f.name)
        : MultipartFile.fromBytes(f.bytes ?? const [], filename: f.name);
    await _api.dio.post<Map<String, dynamic>>(
      ApiEndpoints.fichiersProjet(projetId),
      queryParameters: {'type': piece.type.code},
      data: FormData.fromMap({'fichier': contenu}),
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  List<Map<String, dynamic>> _liste(Map<String, dynamic> body) {
    final r = ApiResponse<List<dynamic>>.fromJson(body, (d) => d as List<dynamic>);
    if (!r.success || r.data == null) throw Exception(r.message);
    return r.data!.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _objet(Map<String, dynamic> body) {
    final r = ApiResponse<Map<String, dynamic>>.fromJson(body, (d) => d as Map<String, dynamic>);
    if (!r.success || r.data == null) throw Exception(r.message);
    return r.data!;
  }
}
