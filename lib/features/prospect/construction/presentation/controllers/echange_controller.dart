import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/construction_providers.dart';

/// Actions de l'acquéreur dans la discussion d'un projet ; l'état indique un envoi en cours.
class EchangeProjetController extends AutoDisposeFamilyNotifier<bool, int> {
  @override
  bool build(int projetId) => false;

  Future<void> envoyerMessage(String texte) =>
      _executer(() => ref.read(projetConstructionRepositoryProvider).envoyerMessage(arg, texte));

  /// L'accord est conclu : le projet passe « accepté ».
  Future<void> accepter(int propositionId) =>
      _executer(() => ref.read(projetConstructionRepositoryProvider).accepterProposition(propositionId));

  Future<void> decliner(int propositionId, String? commentaire) => _executer(
      () => ref.read(projetConstructionRepositoryProvider).refuserProposition(propositionId, commentaire));

  Future<void> _executer(Future<void> Function() action) async {
    state = true;
    try {
      await action();
      ref.invalidate(filProjetProvider(arg));
      ref.invalidate(projetDetailProvider(arg));
      ref.invalidate(mesProjetsProvider);
    } finally {
      state = false;
    }
  }
}

final echangeProjetControllerProvider =
    AutoDisposeNotifierProviderFamily<EchangeProjetController, bool, int>(EchangeProjetController.new);
