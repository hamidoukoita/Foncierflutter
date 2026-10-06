import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

/// Shell agent / société promotrice.
class AgentShell extends ConsumerWidget {
  const AgentShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text('Espace agent'),
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
                user?.fullName ?? 'Agent',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryBlueAnthracite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.societeNom ?? 'Société non renseignée',
                style: const TextStyle(color: AppColors.primaryOcre, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                'Socle agent prêt.\nÀ brancher : dashboard KPI, réservations, RDV.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
