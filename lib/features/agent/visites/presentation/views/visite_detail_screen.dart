import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/agent_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/domain/visite_statut.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/providers/agent_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/agent/shared/widgets/agent_async_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/back_title_header.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';
import '../controllers/visite_detail_controller.dart';
import '../widgets/bien_cadastre_card.dart';
import '../widgets/compte_rendu_field.dart';
import '../widgets/visite_resume_card.dart';

/// Fiche visite & saisie du compte-rendu.
class VisiteDetailScreen extends ConsumerWidget {
  final int visiteId;

  const VisiteDetailScreen({super.key, required this.visiteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visite = ref.watch(visiteDetailProvider(visiteId));

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BackTitleHeader(title: 'Fiche Visite & Compte-rendu'),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: AgentAsyncView<RendezVousModel?>(
                  value: visite,
                  onRetry: () => ref.invalidate(agentVisitesProvider),
                  builder: (v) => v == null
                      ? const EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'Visite introuvable',
                          message: 'Cette visite ne vous est plus assignée.',
                        )
                      : _VisiteDetailContenu(visite: v),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisiteDetailContenu extends ConsumerStatefulWidget {
  final RendezVousModel visite;

  const _VisiteDetailContenu({required this.visite});

  @override
  ConsumerState<_VisiteDetailContenu> createState() =>
      _VisiteDetailContenuState();
}

class _VisiteDetailContenuState extends ConsumerState<_VisiteDetailContenu> {
  late final TextEditingController _compteRendu =
      TextEditingController(text: widget.visite.compteRendu);
  bool _enCours = false;

  @override
  void dispose() {
    _compteRendu.dispose();
    super.dispose();
  }

  Future<void> _executer(
    Future<void> Function(VisiteActions actions) action,
    String succes, {
    bool fermer = false,
  }) async {
    setState(() => _enCours = true);
    try {
      await action(ref.read(visiteActionsProvider));
      if (!mounted) return;
      AppSnackbar.success(context, succes);
      if (fermer) context.pop();
    } catch (e) {
      if (mounted) AppSnackbar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  void _enregistrer() {
    if (_compteRendu.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Le compte-rendu est vide.');
      return;
    }
    _executer(
      (a) => a.enregistrerCompteRendu(widget.visite, _compteRendu.text),
      'Compte-rendu enregistré.',
      fermer: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visite = widget.visite;
    final statut = visite.statutVisite();
    final bien = visite.bienId == null
        ? null
        : ref.watch(bienFoncierProvider(visite.bienId!)).valueOrNull;

    return ListView(
      children: [
        VisiteResumeCard(
          visite: visite,
          bien: bien,
          onAppeler: () =>
              AgentActions.appeler(context, visite.acquereurTelephone),
          onLocaliser: () => AgentActions.itineraireIndisponible(context),
        ),
        if (bien != null) ...[
          const SizedBox(height: AppSpacing.md),
          BienCadastreCard(bien: bien),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (statut == VisiteStatut.refusee)
          Text(
            'Visite refusée${visite.motifRefus == null ? '' : ' : ${visite.motifRefus}'}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed),
          )
        else ...[
          if (statut == VisiteStatut.aReconfirmer) ...[
            PrimaryButton(
              text: 'Confirmer le créneau',
              isSecondary: true,
              isLoading: _enCours,
              onPressed: () => _executer(
                (a) => a.confirmerCreneau(visite.id),
                'Créneau confirmé.',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          CompteRenduField(controller: _compteRendu, enabled: !_enCours),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            text: 'Enregistrer le compte-rendu ›',
            isLoading: _enCours,
            onPressed: _enregistrer,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
