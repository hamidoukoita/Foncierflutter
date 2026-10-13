import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/confirm_dialog.dart';

/// Session de l'acquéreur : déconnexion confirmée puis retour à la connexion.
class ProspectSession {
  ProspectSession._();

  static Future<void> deconnecter(BuildContext context, WidgetRef ref) async {
    final confirme = await ConfirmDialog.show(
      context,
      icon: Icons.logout_rounded,
      title: 'Se déconnecter ?',
      message:
          'Vos réservations et visites restent enregistrées sur votre compte.',
      confirmLabel: 'Se déconnecter',
      destructive: true,
    );
    if (!confirme || !context.mounted) return;
    final router = GoRouter.of(context);
    await ref.read(authProvider.notifier).logout();
    router.go('/login');
  }
}
