import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/confirm_dialog.dart';

/// Gestion de la session de l'agent (déconnexion confirmée).
class AgentSession {
  AgentSession._();

  static const String _routeConnexion = '/login';

  static Future<void> deconnecter(BuildContext context, WidgetRef ref) async {
    final confirme = await ConfirmDialog.show(
      context,
      icon: Icons.logout_rounded,
      title: 'Se déconnecter ?',
      message:
          'Vous devrez saisir à nouveau vos identifiants pour accéder à vos visites.',
      confirmLabel: 'Se déconnecter',
      destructive: true,
    );
    if (!confirme || !context.mounted) return;

    // Le routeur est capturé avant la déconnexion : l'écran agent
    // sera démonté dès que la session sera vidée.
    final router = GoRouter.of(context);
    await ref.read(authProvider.notifier).logout();
    router.go(_routeConnexion);
  }
}
