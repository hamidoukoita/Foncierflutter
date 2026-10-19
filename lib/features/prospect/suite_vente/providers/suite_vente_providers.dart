import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_remplacement_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';

/// Réservations dont le bien a été vendu à un autre acquéreur et qui attendent le choix de l'acquéreur.
final reservationsAChoisirProvider = Provider.autoDispose<List<ReservationModel>>((ref) {
  final reservations = ref.watch(mesReservationsProvider).valueOrNull ?? const [];
  return reservations.where((r) => r.choixAttendu).toList();
});

/// Biens disponibles de la même société sur lesquels reporter la réservation.
final biensRemplacementProvider =
    FutureProvider.autoDispose.family<List<BienRemplacementModel>, int>((ref, reservationId) {
  return ref.watch(reservationRepositoryProvider).biensRemplacement(reservationId);
});
