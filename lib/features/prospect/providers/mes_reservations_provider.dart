import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

final mesReservationsProvider =
    FutureProvider.autoDispose<List<ReservationModel>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) throw Exception('Non connecté');
  return ref.watch(reservationRepositoryProvider).getReservationsByAcquereur(user.id);
});
