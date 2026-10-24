import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/notification_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

/// Notifications de l'acquéreur connecté, de la plus récente à la plus ancienne.
class MesNotificationsController extends AutoDisposeAsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final user = ref.watch(authProvider).user;
    if (user == null) return const [];
    final liste = await ref.watch(notificationRepositoryProvider).getByUtilisateur(user.id);
    return [...liste]..sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));
  }

  /// Marque la notification lue (localement d'abord, pour que la pastille réagisse tout de suite).
  Future<void> marquerLue(NotificationModel n) async {
    if (n.lue) return;
    _remplacer((liste) => [for (final x in liste) x.id == n.id ? x.marqueeLue() : x]);
    await ref.read(notificationRepositoryProvider).marquerLue(n.id);
  }

  Future<void> toutMarquerLu() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    _remplacer((liste) => [for (final x in liste) x.marqueeLue()]);
    await ref.read(notificationRepositoryProvider).toutMarquerLu(user.id);
  }

  /// Ouvrir un élément (ex. un projet) vaut lecture de ses notifications.
  Future<void> marquerLuesPourCible(String cibleType, int cibleId) async {
    bool concerne(NotificationModel n) => n.cibleType == cibleType && n.cibleId == cibleId;
    _remplacer((liste) => [for (final x in liste) concerne(x) ? x.marqueeLue() : x]);
    await ref.read(notificationRepositoryProvider).marquerLuesPourCible(cibleType, cibleId);
  }

  void _remplacer(List<NotificationModel> Function(List<NotificationModel>) maj) {
    final actuelles = state.valueOrNull;
    if (actuelles != null) state = AsyncData(maj(actuelles));
  }
}

final mesNotificationsProvider =
    AutoDisposeAsyncNotifierProvider<MesNotificationsController, List<NotificationModel>>(
        MesNotificationsController.new);

/// Nombre de notifications non lues, affiché dans la pastille de la cloche.
final notificationsNonLuesProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(mesNotificationsProvider).valueOrNull?.where((n) => !n.lue).length ?? 0,
);
