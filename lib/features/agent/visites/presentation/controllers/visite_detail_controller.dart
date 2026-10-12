import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';

/// Visite assignée identifiée par son id (issue du planning déjà chargé).
final visiteDetailProvider =
    Provider.autoDispose.family<AsyncValue<RendezVousModel?>, int>((ref, id) {
  return ref.watch(agentVisitesProvider).whenData((visites) {
    for (final v in visites) {
      if (v.id == id) return v;
    }
    return null;
  });
});

/// Actions de l'agent sur une visite ; rafraîchit le planning après succès.
class VisiteActions {
  final Ref _ref;

  VisiteActions(this._ref);

  Future<void> confirmerCreneau(int visiteId) async {
    await _ref.read(rendezVousRepositoryProvider).accepter(visiteId);
    _ref.invalidate(agentVisitesProvider);
  }

  Future<void> enregistrerCompteRendu(
    RendezVousModel visite,
    String compteRendu,
  ) async {
    await _ref
        .read(rendezVousRepositoryProvider)
        .enregistrerCompteRendu(visite, compteRendu.trim());
    _ref.invalidate(agentVisitesProvider);
  }
}

final visiteActionsProvider = Provider<VisiteActions>(VisiteActions.new);
