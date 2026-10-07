import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/repositories/bien_foncier_repository.dart';
import 'package:flutter_mobile_prospect_agent/data/repositories/reservation_repository.dart';
import 'package:flutter_mobile_prospect_agent/data/repositories/rendez_vous_repository.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

final bienFoncierRepositoryProvider = Provider<BienFoncierRepository>((ref) {
  return BienFoncierRepository(ref.watch(apiClientProvider));
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository(ref.watch(apiClientProvider));
});

final rendezVousRepositoryProvider = Provider<RendezVousRepository>((ref) {
  return RendezVousRepository(ref.watch(apiClientProvider));
});
