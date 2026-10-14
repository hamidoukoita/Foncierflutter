import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import '../data/maison_cle_en_main_repository.dart';
import '../domain/maison_cle_en_main.dart';

final maisonRepositoryProvider = Provider<MaisonCleEnMainRepository>(
  (ref) => MaisonCleEnMainRepository(ref.watch(apiClientProvider)),
);

final catalogueMaisonsProvider = FutureProvider.autoDispose<List<MaisonCleEnMain>>(
  (ref) => ref.watch(maisonRepositoryProvider).catalogue(),
);

/// Maisons d'une société : proposées comme référence dans un projet de construction.
final maisonsSocieteProvider = FutureProvider.autoDispose.family<List<MaisonCleEnMain>, int>(
  (ref, societeId) => ref.watch(maisonRepositoryProvider).deSociete(societeId),
);

final maisonDetailProvider = FutureProvider.autoDispose.family<MaisonCleEnMain, int>(
  (ref, id) => ref.watch(maisonRepositoryProvider).detail(id),
);
