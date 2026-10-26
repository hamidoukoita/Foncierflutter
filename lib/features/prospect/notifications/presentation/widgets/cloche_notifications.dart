import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/pastille_compteur.dart';
import '../../notifications_routes.dart';
import '../../providers/notifications_providers.dart';

/// Cloche de l'en-tête : ouvre les notifications, avec une pastille quand il y en a de non lues.
class ClocheNotifications extends ConsumerWidget {
  const ClocheNotifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nonLues = ref.watch(notificationsNonLuesProvider);
    return Semantics(
      label: nonLues > 0 ? 'Notifications, $nonLues non lue${nonLues > 1 ? 's' : ''}' : 'Notifications',
      button: true,
      excludeSemantics: true,
      child: PastilleCompteur(
        nombre: nonLues,
        child: CircleIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () => context.push(NotificationsRoutes.liste),
        ),
      ),
    );
  }
}
