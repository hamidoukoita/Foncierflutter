import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/notifications/notifications_systeme.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/providers/demarrage_provider.dart';

/// Relaie sur le téléphone les nouvelles notifications du compte connecté (acquéreur ou agent) :
/// le serveur est interrogé à l'ouverture, au retour au premier plan puis chaque minute.
/// Au tout premier lancement, l'historique existant est marqué comme déjà signalé.
class SurveillanceNotifications extends ConsumerStatefulWidget {
  final Widget child;

  /// Appelé quand de nouvelles notifications arrivent, pour rafraîchir les écrans concernés.
  final void Function(WidgetRef ref)? onNouvelles;

  const SurveillanceNotifications({super.key, required this.child, this.onNouvelles});

  static const Duration intervalle = Duration(minutes: 1);

  /// Nombre maximal de notifications système affichées d'un coup.
  static const int _maxAffichees = 3;

  @override
  ConsumerState<SurveillanceNotifications> createState() => _SurveillanceNotificationsState();
}

class _SurveillanceNotificationsState extends ConsumerState<SurveillanceNotifications> with WidgetsBindingObserver {
  Timer? _minuteur;
  bool _enCours = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationsSysteme.demanderAutorisation();
    _verifier();
    _minuteur = Timer.periodic(SurveillanceNotifications.intervalle, (_) => _verifier());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _minuteur?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState etat) {
    if (etat == AppLifecycleState.resumed) _verifier();
  }

  Future<void> _verifier() async {
    final utilisateur = ref.read(authProvider).user;
    if (utilisateur == null || _enCours) return;
    _enCours = true;
    try {
      final preferences = ref.read(preferencesAppProvider);
      final notifications = await ref.read(notificationRepositoryProvider).getByUtilisateur(utilisateur.id);
      if (notifications.isEmpty) return;
      final plusRecente = notifications.map((n) => n.id).reduce((a, b) => a > b ? a : b);
      final derniere = await preferences.derniereNotificationSignalee(utilisateur.id);

      if (derniere != null) {
        final nouvelles = notifications.where((n) => n.id > derniere && !n.lue).toList()
          ..sort((a, b) => b.id.compareTo(a.id));
        for (final n in nouvelles.take(SurveillanceNotifications._maxAffichees)) {
          await NotificationsSysteme.afficher(id: n.id, titre: n.titre, message: n.message);
        }
        if (nouvelles.isNotEmpty && mounted) widget.onNouvelles?.call(ref);
      }
      if (derniere == null || plusRecente > derniere) {
        await preferences.memoriserNotificationSignalee(utilisateur.id, plusRecente);
      }
    } catch (e) {
      // Réseau indisponible : nouvelle tentative au prochain passage.
      debugPrint('Vérification des notifications impossible : $e');
    } finally {
      _enCours = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
