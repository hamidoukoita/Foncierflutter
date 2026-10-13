import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/agent_planning.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/reservation_suivi.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';

/// Nombre de réservations affichées sur la vue d'ensemble.
const int _apercuReservations = 2;

class AgentDashboardState {
  final int visitesDuJour;
  final int dossiersEnCours;
  final RendezVousModel? prochaineVisite;
  final List<ReservationModel> reservationsSuivies;

  const AgentDashboardState({
    required this.visitesDuJour,
    required this.dossiersEnCours,
    required this.prochaineVisite,
    required this.reservationsSuivies,
  });

  List<ReservationModel> get apercuReservations =>
      reservationsSuivies.take(_apercuReservations).toList();

  factory AgentDashboardState.depuis(
    List<RendezVousModel> visites,
    List<ReservationModel> reservations,
    DateTime maintenant,
  ) {
    return AgentDashboardState(
      visitesDuJour: AgentPlanning.duJour(visites, maintenant).length,
      dossiersEnCours: ReservationsSuivi.dossiersEnCours(reservations),
      prochaineVisite: AgentPlanning.prochaine(visites, maintenant),
      reservationsSuivies: ReservationsSuivi.trier(reservations),
    );
  }
}

final agentDashboardProvider = FutureProvider<AgentDashboardState>((ref) async {
  final visites = await ref.watch(agentVisitesProvider.future);
  final reservations = await ref.watch(agentReservationsProvider.future);
  return AgentDashboardState.depuis(visites, reservations, DateTime.now());
});

/// Recharge toutes les données de la vue d'ensemble.
Future<void> rafraichirDashboardAgent(WidgetRef ref) async {
  ref
    ..invalidate(agentVisitesProvider)
    ..invalidate(agentReservationsProvider);
  await ref.read(agentDashboardProvider.future);
}
