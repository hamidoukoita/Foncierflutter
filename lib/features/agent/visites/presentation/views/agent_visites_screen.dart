import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/agent_async_view.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import '../controllers/agent_planning_controller.dart';
import '../widgets/day_selector_strip.dart';
import '../widgets/planning_header.dart';
import '../widgets/visite_filter_tabs.dart';
import '../widgets/visite_list.dart';

/// Planning des visites assignées à l'agent.
class AgentVisitesScreen extends ConsumerWidget {
  const AgentVisitesScreen({super.key});

  Future<void> _choisirDate(BuildContext context, WidgetRef ref) async {
    final ui = ref.read(planningUiProvider);
    final choisie = await showDatePicker(
      context: context,
      initialDate: ui.jourSelectionne,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Choisir une date',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (choisie != null) ref.read(planningUiProvider.notifier).allerA(choisie);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(planningUiProvider);
    final controller = ref.read(planningUiProvider.notifier);
    final vue = ref.watch(planningVueProvider);
    final societeNom = ref.watch(authProvider).user?.societeNom;
    final donnees = vue.valueOrNull;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primaryOcre,
        onRefresh: () async {
          ref.invalidate(agentVisitesProvider);
          await ref.read(agentVisitesProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
          children: [
            PlanningHeader(
              societeNom: societeNom,
              onCalendrier: () => _choisirDate(context, ref),
            ),
            const SizedBox(height: AppSpacing.lg),
            DaySelectorStrip(
              jours: ui.jours,
              jourSelectionne: ui.jourSelectionne,
              aDesVisites: (jour) => donnees?.aDesVisites(jour) ?? false,
              onSelect: controller.selectionnerJour,
            ),
            const SizedBox(height: AppSpacing.md),
            VisiteFilterTabs(
              selection: ui.onglet,
              compteurs: {
                OngletVisites.ceJour: donnees?.ceJour.length,
                OngletVisites.aVenir: donnees?.aVenir.length,
                OngletVisites.effectuees: null,
              },
              onChanged: controller.changerOnglet,
            ),
            const SizedBox(height: AppSpacing.md),
            AgentAsyncView<PlanningVue>(
              value: vue,
              onRetry: () => ref.invalidate(agentVisitesProvider),
              builder: (data) => VisiteList(
                visites: data.pour(ui.onglet),
                onglet: ui.onglet,
                prochaineId: data.prochaineId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
