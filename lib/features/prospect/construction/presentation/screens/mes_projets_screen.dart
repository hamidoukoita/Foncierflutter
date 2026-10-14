import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';
import '../../construction_routes.dart';
import '../../providers/construction_providers.dart';
import '../widgets/projet_card.dart';

/// Onglet « Construire » : tous les projets de construction de l'acquéreur (en-tête fourni par le shell).
class MesProjetsScreen extends ConsumerWidget {
  const MesProjetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mesProjetsProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
                error: (e, _) => EmptyStateView(
                  icon: Icons.cloud_off_rounded,
                  title: 'Projets indisponibles',
                  message: ErrorHandler.messageOf(e),
                  onRetry: () => ref.invalidate(mesProjetsProvider),
                ),
                data: (projets) => projets.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.home_work_outlined,
                        title: 'Aucun projet',
                        message: 'Soumettez votre premier projet pour faire construire sur votre terrain.',
                      )
                    : RefreshIndicator(
                        color: AppColors.primaryOcre,
                        onRefresh: () async => ref.invalidate(mesProjetsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                          itemCount: projets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md - AppSpacing.xs),
                          itemBuilder: (_, i) => ProjetCard(
                            projet: projets[i],
                            onTap: () => context.push(ConstructionRoutes.detail(projets[i].id)),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, AppSpacing.md),
              child: PrimaryButton(
                text: 'Soumettre un nouveau projet',
                icon: Icons.add_home_outlined,
                onPressed: () => context.push(ConstructionRoutes.nouveau),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
