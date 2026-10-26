import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import '../domain/echange_projet.dart';
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

  /// Messages et propositions échangés avec la société, par ordre chronologique.
  Future<List<ElementFil>> fil(int projetId) async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.filProjet(projetId));
    return _liste(res.data!).map(ElementFil.fromJson).whereType<ElementFil>().toList();
  }

  Future<void> envoyerMessage(int projetId, String texte) async {
    final res = await _api.post<Map<String, dynamic>>(ApiEndpoints.messagesProjet(projetId), data: {'texte': texte});
    _objet(res.data!);
  }

  /// Retenir la proposition : le projet est accepté selon ses conditions.
  Future<void> accepterProposition(int propositionId) async {
    final res = await _api.patch<Map<String, dynamic>>(ApiEndpoints.accepterProposition(propositionId));
    _objet(res.data!);
  }

  Future<void> refuserProposition(int propositionId, String? commentaire) async {
    final res = await _api.patch<Map<String, dynamic>>(ApiEndpoints.refuserProposition(propositionId),
        data: {if (commentaire != null && commentaire.trim().isNotEmpty) 'commentaire': commentaire.trim()});
    _objet(res.data!);
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
