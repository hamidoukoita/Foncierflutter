import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/agent_kpi_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

class AgentDashboardState {
  final AgentKpiModel kpis;
  final List<ReservationModel> reservationsDuJour;
  final List<RendezVousModel> visitesAssignees;
  final String filtreStatut;

  const AgentDashboardState({
    this.kpis = const AgentKpiModel(),
    this.reservationsDuJour = const [],
    this.visitesAssignees = const [],
    this.filtreStatut = 'TOUT',
  });

  AgentDashboardState copyWith({
    AgentKpiModel? kpis,
    List<ReservationModel>? reservationsDuJour,
    List<RendezVousModel>? visitesAssignees,
    String? filtreStatut,
  }) {
    return AgentDashboardState(
      kpis: kpis ?? this.kpis,
      reservationsDuJour: reservationsDuJour ?? this.reservationsDuJour,
      visitesAssignees: visitesAssignees ?? this.visitesAssignees,
      filtreStatut: filtreStatut ?? this.filtreStatut,
    );
  }
}

class AgentDashboardNotifier extends AsyncNotifier<AgentDashboardState> {
  @override
  Future<AgentDashboardState> build() async {
    return _fetchData();
  }

  Future<AgentDashboardState> _fetchData() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      throw Exception('Agent non connecté');
    }

    final resRepo = ref.read(reservationRepositoryProvider);
    final rdvRepo = ref.read(rendezVousRepositoryProvider);

    try {
      final reservations = await resRepo.getReservationsByAgent();
      final rdvs = await rdvRepo
          .getRendezVous(); // Filtrer par agent dans le repo ou ici

      // Calcul des KPIs locaux pour la maquette
      int visitesJour = rdvs.where((r) => r.statut == 'PLANIFIE').length;
      int enAttente =
          reservations.where((r) => r.statut == 'EN_ATTENTE').length;
      int expirees = reservations
          .where((r) =>
              r.statut == 'EN_ATTENTE' &&
              DateTime.now().isAfter(r.dateExpiration))
          .length;
      int confirmees =
          reservations.where((r) => r.statut == 'CONFIRMER').length;

      final kpis = AgentKpiModel(
        totalVisitesJour: visitesJour,
        reservationsEnAttente: enAttente,
        reservationsExpirees: expirees,
        totalReservationsConfirmees: confirmees,
      );

      return AgentDashboardState(
        kpis: kpis,
        reservationsDuJour: reservations,
        visitesAssignees: rdvs,
      );
    } catch (e) {
      throw Exception('Erreur de chargement du tableau de bord : $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _fetchData();
      state = AsyncValue.data(
          data.copyWith(filtreStatut: state.valueOrNull?.filtreStatut));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setFiltreStatut(String statut) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(filtreStatut: statut));
    }
  }
}

final agentDashboardProvider =
    AsyncNotifierProvider<AgentDashboardNotifier, AgentDashboardState>(
  AgentDashboardNotifier.new,
);
