import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/agent_planning.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';

enum OngletVisites { ceJour, aVenir, effectuees }

/// Nombre de jours visibles dans le bandeau de dates.
const int joursVisibles = 7;

class PlanningUiState {
  final DateTime debutFenetre;
  final DateTime jourSelectionne;
  final OngletVisites onglet;

  const PlanningUiState({
    required this.debutFenetre,
    required this.jourSelectionne,
    this.onglet = OngletVisites.ceJour,
  });

  List<DateTime> get jours =>
      List.generate(joursVisibles, (i) => debutFenetre.add(Duration(days: i)));

  PlanningUiState copyWith({
    DateTime? debutFenetre,
    DateTime? jourSelectionne,
    OngletVisites? onglet,
  }) =>
      PlanningUiState(
        debutFenetre: debutFenetre ?? this.debutFenetre,
        jourSelectionne: jourSelectionne ?? this.jourSelectionne,
        onglet: onglet ?? this.onglet,
      );
}

class PlanningUiController extends Notifier<PlanningUiState> {
  @override
  PlanningUiState build() => _centreSur(DateTime.now());

  PlanningUiState _centreSur(DateTime jour) {
    final j = DateFormatter.debutDuJour(jour);
    return PlanningUiState(
      // La veille reste visible, comme sur la maquette.
      debutFenetre: j.subtract(const Duration(days: 1)),
      jourSelectionne: j,
    );
  }

  void selectionnerJour(DateTime jour) => state = state.copyWith(
        jourSelectionne: DateFormatter.debutDuJour(jour),
        onglet: OngletVisites.ceJour,
      );

  /// Repositionne le bandeau sur une date choisie au calendrier.
  void allerA(DateTime jour) => state = _centreSur(jour);

  void changerOnglet(OngletVisites onglet) =>
      state = state.copyWith(onglet: onglet);
}

final planningUiProvider =
    NotifierProvider<PlanningUiController, PlanningUiState>(
        PlanningUiController.new);

/// Listes prêtes à afficher pour chaque onglet.
class PlanningVue {
  final List<RendezVousModel> toutes;
  final List<RendezVousModel> ceJour;
  final List<RendezVousModel> aVenir;
  final List<RendezVousModel> effectuees;
  final int? prochaineId;

  const PlanningVue({
    required this.toutes,
    required this.ceJour,
    required this.aVenir,
    required this.effectuees,
    required this.prochaineId,
  });

  List<RendezVousModel> pour(OngletVisites onglet) => switch (onglet) {
        OngletVisites.ceJour => ceJour,
        OngletVisites.aVenir => aVenir,
        OngletVisites.effectuees => effectuees,
      };

  bool aDesVisites(DateTime jour) => AgentPlanning.aDesVisites(toutes, jour);
}

final planningVueProvider = Provider<AsyncValue<PlanningVue>>((ref) {
  final jour = ref.watch(planningUiProvider.select((s) => s.jourSelectionne));
  return ref.watch(agentVisitesProvider).whenData((visites) {
    final now = DateTime.now();
    return PlanningVue(
      toutes: visites,
      ceJour: AgentPlanning.duJour(visites, jour),
      aVenir: AgentPlanning.aVenir(visites, now),
      effectuees: AgentPlanning.effectuees(visites, now),
      prochaineId: AgentPlanning.prochaine(visites, now)?.id,
    );
  });
});
