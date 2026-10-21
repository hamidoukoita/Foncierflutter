import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/lien_panorama_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/creneau_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';

/// Parcelles individuelles publiées (onglet « Parcelles »).
final parcellesProvider =
    FutureProvider.autoDispose<List<BienFoncierModel>>((ref) async {
  return ref.watch(bienFoncierRepositoryProvider).getParcelles();
});

/// Détail d'un bien (lot ou parcelle) via la vue polymorphique du backend.
final bienDetailProvider =
    FutureProvider.autoDispose.family<BienFoncierModel, int>((ref, id) async {
  return ref.watch(bienFoncierRepositoryProvider).getById(id);
});

/// Rendez-vous de l'acquéreur connecté (onglet « Mes visites »).
final mesVisitesProvider =
    FutureProvider.autoDispose<List<RendezVousModel>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) throw Exception('Non connecté');
  return ref
      .watch(rendezVousRepositoryProvider)
      .getRendezVousByAcquereur(user.id);
});

/// Photos et panoramas 360° d'un bien.
final mediasBienProvider = FutureProvider.autoDispose
    .family<List<MediaModel>, int>((ref, bienId) async {
  return ref.watch(mediaRepositoryProvider).getByBien(bienId);
});

/// Points de passage de la visite virtuelle d'un bien (maisons clés en main).
final liensPanoramasProvider = FutureProvider.autoDispose
    .family<List<LienPanoramaModel>, int>((ref, bienId) async {
  return ref.watch(mediaRepositoryProvider).getLiensByBien(bienId);
});

/// Ce que l'acquéreur connecté peut faire sur un bien : réserver, visiter, ou pourquoi pas.
final conditionsReservationProvider = FutureProvider.autoDispose
    .family<ConditionsReservation, int>((ref, bienId) async {
  return ref.watch(reservationRepositoryProvider).conditions(bienId);
});

/// Créneaux de visite disponibles d'une société promotrice.
final creneauxSocieteProvider = FutureProvider.autoDispose
    .family<List<CreneauModel>, int>((ref, societeId) async {
  return ref.watch(creneauRepositoryProvider).getDisponibles(societeId);
});

/// Photos et panoramas 360° d'un programme (cité).
final programmeMediasProvider = FutureProvider.autoDispose
    .family<List<MediaModel>, int>((ref, programmeId) async {
  return ref.watch(mediaRepositoryProvider).getByProgramme(programmeId);
});

/// Plan de masse d'un programme (null si non créé).
final planMasseProvider = FutureProvider.autoDispose
    .family<PlanMasse?, int>((ref, programmeId) async {
  return ref.watch(planMasseRepositoryProvider).getByProgramme(programmeId);
});
