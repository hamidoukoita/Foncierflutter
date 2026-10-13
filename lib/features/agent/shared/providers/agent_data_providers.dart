import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/auth_models.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

/// Agent connecté (lève une erreur si la session est absente).
final agentConnecteProvider = Provider<AuthUser>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) throw StateError('Agent non connecté');
  return user;
});

/// Visites assignées à l'agent connecté.
final agentVisitesProvider = FutureProvider<List<RendezVousModel>>((ref) {
  final agent = ref.watch(agentConnecteProvider);
  return ref.watch(rendezVousRepositoryProvider).getRendezVousByAgent(agent.id);
});

/// Réservations sous le suivi de l'agent connecté.
final agentReservationsProvider = FutureProvider<List<ReservationModel>>((ref) {
  final agent = ref.watch(agentConnecteProvider);
  return ref
      .watch(reservationRepositoryProvider)
      .getReservationsByAgent(agent.id);
});

/// Fiche d'un bien foncier (lot ou parcelle).
final bienFoncierProvider =
    FutureProvider.autoDispose.family<BienFoncierModel, int>((ref, id) {
  return ref.watch(bienFoncierRepositoryProvider).getById(id);
});
