import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import '../data/projet_construction_repository.dart';
import '../domain/echange_projet.dart';
import '../domain/modele_maison.dart';
import '../domain/projet_construction.dart';
import '../domain/societe_promotrice.dart';

final projetConstructionRepositoryProvider = Provider<ProjetConstructionRepository>(
  (ref) => ProjetConstructionRepository(ref.watch(apiClientProvider)),
);

final societesAgreeesProvider = FutureProvider.autoDispose<List<SocietePromotrice>>(
  (ref) => ref.watch(projetConstructionRepositoryProvider).societesAgreees(),
);

final modelesSocieteProvider = FutureProvider.autoDispose.family<List<ModeleMaison>, int>(
  (ref, societeId) => ref.watch(projetConstructionRepositoryProvider).modelesDeSociete(societeId),
);

/// Photos et panoramas 360° d'un modèle du catalogue.
final mediasModeleProvider = FutureProvider.autoDispose.family<List<MediaModel>, int>(
  (ref, modeleId) => ref.watch(mediaRepositoryProvider).getByModele(modeleId),
);

/// Projets de l'acquéreur connecté, du plus récent au plus ancien.
final mesProjetsProvider = FutureProvider.autoDispose<List<ProjetConstruction>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return const [];
  return ref.watch(projetConstructionRepositoryProvider).mesProjets(user.id);
});

/// Fil d'échange d'un projet avec sa société.
final filProjetProvider = FutureProvider.autoDispose.family<List<ElementFil>, int>(
  (ref, id) => ref.watch(projetConstructionRepositoryProvider).fil(id),
);

final projetDetailProvider = FutureProvider.autoDispose.family<ProjetConstruction, int>(
  (ref, id) => ref.watch(projetConstructionRepositoryProvider).projet(id),
);
