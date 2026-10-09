import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';

/// Liste des programmes (catalogue public / acquéreur).
final programmesProvider = FutureProvider.autoDispose<List<ProgrammeFoncier>>((ref) async {
  return ref.watch(programmeRepositoryProvider).getAll();
});

/// Détail d'un programme.
final programmeDetailProvider =
    FutureProvider.autoDispose.family<ProgrammeFoncier, int>((ref, id) async {
  return ref.watch(programmeRepositoryProvider).getById(id);
});

/// Lots d'un programme.
final lotsByProgrammeProvider =
    FutureProvider.autoDispose.family<List<LotProgramme>, int>((ref, programmeId) async {
  return ref.watch(lotProgrammeRepositoryProvider).getByProgramme(programmeId);
});

/// Détail d'un lot.
final lotDetailProvider =
    FutureProvider.autoDispose.family<LotProgramme, int>((ref, id) async {
  return ref.watch(lotProgrammeRepositoryProvider).getById(id);
});
