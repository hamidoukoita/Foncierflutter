import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifications système du téléphone (barre de notifications), affichées par l'application
/// elle-même : sans service push, elles apparaissent quand l'application est ouverte
/// ou encore active en arrière-plan.
class NotificationsSysteme {
  NotificationsSysteme._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _pret = false;

  static const AndroidNotificationDetails _canalAndroid = AndroidNotificationDetails(
    'foncier_dossiers',
    'Suivi de vos dossiers',
    channelDescription: 'Réservations, visites et remboursements',
    importance: Importance.high,
    priority: Priority.high,
  );

  /// À appeler une fois au démarrage ; sans effet sur les plateformes non prises en charge.
  static Future<void> initialiser() async {
    if (kIsWeb || _pret) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      _pret = true;
    } catch (e) {
      debugPrint('Notifications système indisponibles : $e');
    }
  }

  /// Android 13+ : autorisation demandée une seule fois par le système.
  static Future<void> demanderAutorisation() async {
    if (!_pret) return;
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> afficher({required int id, required String titre, required String message}) async {
    if (!_pret) return;
    await _plugin.show(
      id: id,
      title: titre,
      body: message,
      notificationDetails: const NotificationDetails(
        android: _canalAndroid,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
