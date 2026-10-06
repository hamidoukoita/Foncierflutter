import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

/// Shell acquéreur / prospect — point d'entrée après login.
/// Les features (catalogue, réservations…) se branchent ici.
class ProspectShell extends ConsumerWidget {
  const ProspectShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Foncier+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bonjour ${user?.prenom ?? ''}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryBlueAnthracite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Espace acquéreur — socle prêt.\nProchaine étape : brancher le catalogue programmes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 24),
              Text(
                'Rôle : ${user?.role ?? '—'} · ${user?.telephone ?? ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: 'Lots'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'Réservations'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onDestinationSelected: (_) {},
      ),
    );
  }
}
