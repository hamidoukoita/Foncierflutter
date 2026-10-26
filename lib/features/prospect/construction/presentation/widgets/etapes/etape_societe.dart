import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../../providers/construction_providers.dart';
import '../../controllers/soumission_controller.dart';
import '../societe_tile.dart';
import 'entete_etape.dart';

/// Étape 1 : choix de la société promotrice agréée qui recevra le dossier.
class EtapeSociete extends ConsumerWidget {
  const EtapeSociete({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societes = ref.watch(societesAgreeesProvider);
    final choisie = ref.watch(soumissionControllerProvider.select((s) => s.societe));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EnteteEtape(
          titre: 'Choisissez la société qui construira votre maison',
          texte: 'Seules les sociétés agréées par le ministère peuvent recevoir votre projet. '
              'Vous verrez ensuite leurs modèles de maison.',
        ),
        societes.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
          ),
          error: (e, _) => EmptyStateView(
            icon: Icons.cloud_off_rounded,
            title: 'Sociétés indisponibles',
            message: ErrorHandler.messageOf(e),
            onRetry: () => ref.invalidate(societesAgreeesProvider),
          ),
          data: (liste) => liste.isEmpty
              ? const EmptyStateView(
                  icon: Icons.business_outlined,
                  title: 'Aucune société agréée',
                  message: 'Aucun promoteur ne peut recevoir de projet pour le moment.',
                )
              : Column(
                  children: [
                    for (final s in liste)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xxs),
                        child: SocieteTile(
                          societe: s,
                          selectionnee: choisie?.id == s.id,
                          onTap: () => ref.read(soumissionControllerProvider.notifier).choisirSociete(s),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
