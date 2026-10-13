import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/proximite_commodite_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import '../../domain/lieu_carte.dart';
import '../../domain/lieu_carte_builder.dart';

/// Commodités de proximité d'une cité ; une erreur réseau ne bloque pas la carte.
final proximitesProgrammeProvider = FutureProvider.autoDispose
    .family<List<ProximiteCommoditeModel>, int>((ref, programmeId) => _ouVide(
        () => ref
            .watch(commoditeRepositoryProvider)
            .getProximitesProgramme(programmeId)));

/// Commodités de proximité rattachées directement à un bien.
final proximitesBienProvider = FutureProvider.autoDispose
    .family<List<ProximiteCommoditeModel>, int>((ref, bienId) => _ouVide(() =>
        ref.watch(commoditeRepositoryProvider).getProximitesBien(bienId)));

/// Équipements internes du plan de masse d'une cité.
final equipementsInternesProvider = FutureProvider.autoDispose
    .family<List<String>, int>((ref, programmeId) async {
  final plan = await _ouVide(() async {
    final p = await ref.watch(planMasseProvider(programmeId).future);
    return p == null ? const <PlanMasse>[] : [p];
  });
  return LieuCarteBuilder.equipementsDuPlan(plan.isEmpty ? null : plan.first);
});

/// Carte d'une cité / d'un programme.
final localisationProgrammeProvider =
    FutureProvider.autoDispose.family<LieuCarte, int>((ref, id) async {
  final programme = await ref.watch(programmeDetailProvider(id).future);
  final lots = await _lotsOuVide(ref, id);
  return LieuCarteBuilder.pourProgramme(
    programme,
    lots: lots,
    proximites: await ref.watch(proximitesProgrammeProvider(id).future),
    equipementsInternes:
        await ref.watch(equipementsInternesProvider(id).future),
  );
});

/// Carte d'un bien (parcelle individuelle ou lot) ; la cité ne sert que
/// de repli quand le bien n'a pas ses propres coordonnées.
final localisationBienProvider =
    FutureProvider.autoDispose.family<LieuCarte, int>((ref, id) async {
  final bien = await ref.watch(bienDetailProvider(id).future);
  final proximitesBien = await ref.watch(proximitesBienProvider(id).future);
  final programmeId = bien.programmeId;
  if (programmeId == null) {
    return LieuCarteBuilder.pourBien(bien, proximites: proximitesBien);
  }
  // Lot de cité : il hérite des commodités et des équipements de sa cité.
  ProgrammeFoncier? programme;
  try {
    programme = await ref.watch(programmeDetailProvider(programmeId).future);
  } catch (_) {
    programme = null;
  }
  return LieuCarteBuilder.pourBien(
    bien,
    programme: programme,
    lots: bien.aDesCoordonnees ? const [] : await _lotsOuVide(ref, programmeId),
    proximites: [
      ...proximitesBien,
      ...await ref.watch(proximitesProgrammeProvider(programmeId).future),
    ],
    equipementsInternes:
        await ref.watch(equipementsInternesProvider(programmeId).future),
  );
});

Future<List<LotProgramme>> _lotsOuVide(Ref ref, int programmeId) =>
    _ouVide(() => ref.watch(lotsByProgrammeProvider(programmeId).future));

/// Données secondaires : en cas d'échec, la carte s'affiche sans elles.
Future<List<T>> _ouVide<T>(Future<List<T>> Function() charger) async {
  try {
    return await charger();
  } catch (_) {
    return <T>[];
  }
}
