import 'package:flutter_mobile_prospect_agent/core/constants/api_endpoints.dart';
import 'package:flutter_mobile_prospect_agent/core/network/api_client.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_remplacement_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';

class ReservationRepository {
  final ApiClient _apiClient;

  ReservationRepository(this._apiClient);

  Future<List<ReservationModel>> getReservationsByAcquereur(
      int acquereurId) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>(ApiEndpoints.reservationsByAcquereur(acquereurId));
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map(
              (json) => ReservationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  /// Réservations sous le suivi d'un agent collaborateur.
  Future<List<ReservationModel>> getReservationsByAgent(int agentId) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>(ApiEndpoints.reservationsByAgent(agentId));
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map(
              (json) => ReservationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  /// Montant, durée et disponibilité d'un bien avant de le réserver.
  Future<ConditionsReservation> conditions(int bienId) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>(ApiEndpoints.conditionsReservation(bienId));
    return ConditionsReservation.fromJson(_donnees(response.data!));
  }

  /// Réserve le bien ; pour un lot ou une parcelle, le paiement Orange Money est simulé côté serveur.
  Future<ReservationModel> reserverBien(int bienId, int acquereurId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.reservations,
      data: {'bienId': bienId, 'acquereurId': acquereurId},
    );
    return ReservationModel.fromJson(_donnees(response.data!));
  }

  /// Désistement de l'acquéreur (en attente ou en cours) : le montant payé n'est pas remboursé.
  Future<void> annuler(int reservationId) =>
      _action(ApiEndpoints.annulerReservation(reservationId));

  /// L'agent chargé du dossier démarre le décompte de la réservation.
  Future<ReservationModel> demarrerDecompte(int reservationId) =>
      _action(ApiEndpoints.demarrerReservation(reservationId));

  /// Vente conclue avant l'échéance.
  Future<ReservationModel> conclureVente(int reservationId) =>
      _action(ApiEndpoints.vendreReservation(reservationId));

  /// Biens disponibles de la même société pour reporter une réservation (bien vendu à un autre).
  Future<List<BienRemplacementModel>> biensRemplacement(int reservationId) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>(ApiEndpoints.biensRemplacement(reservationId));
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data!,
      (data) => data as List<dynamic>,
    );
    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!
          .map((json) => BienRemplacementModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(apiResponse.message);
  }

  /// Remboursement sous 24 h du montant payé.
  Future<ReservationModel> demanderRemboursement(int reservationId) =>
      _action(ApiEndpoints.rembourserReservation(reservationId));

  /// Report du montant payé sur un autre bien de la société ; retourne la nouvelle réservation.
  Future<ReservationModel> remplacer(int reservationId, int bienId) =>
      _action(ApiEndpoints.remplacerReservation(reservationId, bienId));

  Future<ReservationModel> _action(String chemin) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(chemin);
    return ReservationModel.fromJson(_donnees(response.data!));
  }

  Map<String, dynamic> _donnees(Map<String, dynamic> body) {
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      body,
      (data) => data as Map<String, dynamic>,
    );
    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }
    return apiResponse.data!;
  }
}
