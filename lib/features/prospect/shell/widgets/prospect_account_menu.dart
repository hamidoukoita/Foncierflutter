import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'profil/profil_avatar.dart';
import 'profil/profil_sheet.dart';

/// Avatar de l'acquéreur dans les en-têtes : ouvre le panneau « Mon profil ».
class ProspectAccountMenu extends ConsumerWidget {
  const ProspectAccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Tooltip(
      message: 'Mon profil',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ProfilSheet.show(context),
        child: ProfilAvatar(user: user),
      ),
    );
  }
}
