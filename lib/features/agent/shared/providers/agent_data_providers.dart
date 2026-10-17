import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
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

/// Réservation suivie par l'agent, identifiée par son id (issue de la liste déjà chargée).
final agentReservationProvider =
    Provider.autoDispose.family<AsyncValue<ReservationModel?>, int>((ref, id) {
  return ref.watch(agentReservationsProvider).whenData((liste) {
    for (final r in liste) {
      if (r.id == id) return r;
    }
    return null;
  });
});

/// Position GPS d'un bien : la sienne, sinon celle de sa cité (lots sans coordonnées propres).
final positionBienProvider = FutureProvider.autoDispose.family<LatLng?, int>((ref, bienId) async {
  final bien = await ref.watch(bienFoncierProvider(bienId).future);
  if (bien.latitude != null && bien.longitude != null) return LatLng(bien.latitude!, bien.longitude!);
  if (bien.programmeId == null) return null;
  final programme = await ref.watch(programmeRepositoryProvider).getById(bien.programmeId!);
  return programme.latitude != null && programme.longitude != null
      ? LatLng(programme.latitude!, programme.longitude!)
      : null;
});
