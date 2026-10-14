import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/back_title_header.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../domain/projet_construction.dart';
import '../../providers/construction_providers.dart';
import '../widgets/projet_statut.dart';
import '../widgets/projet_suivi.dart';

/// Suivi d'un projet de construction par l'acquéreur.
class ProjetDetailScreen extends ConsumerWidget {
  final int projetId;
  const ProjetDetailScreen({super.key, required this.projetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projetDetailProvider(projetId));
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.pageHorizontal, AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: BackTitleHeader(title: 'Mon projet de construction'),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
                error: (e, _) => EmptyStateView(
                  icon: Icons.cloud_off_rounded,
                  title: 'Projet indisponible',
                  message: ErrorHandler.messageOf(e),
                  onRetry: () => ref.invalidate(projetDetailProvider(projetId)),
                ),
                data: (p) => RefreshIndicator(
                  color: AppColors.primaryOcre,
                  onRefresh: () async => ref.invalidate(projetDetailProvider(projetId)),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal, AppSpacing.lg, AppSpacing.pageHorizontal, AppSpacing.xl),
                    children: [
                      _Entete(projet: p),
                      const SizedBox(height: AppSpacing.md),
                      _Section(titre: 'Suivi du dossier', child: ProjetSuivi(projet: p)),
                      _Section(
                        titre: 'Terrain',
                        child: Column(children: [
                          _Info('Titre Foncier', p.numeroTitreFoncier),
                          _Info('Superficie', '${p.superficieTerrain.toStringAsFixed(0)} m²'),
                          if ((p.localisationTerrain ?? '').isNotEmpty) _Info('Localisation', p.localisationTerrain!),
                          if (p.budgetEstime != null) _Info('Budget', CurrencyFormatter.fcfa(p.budgetEstime)),
                        ]),
                      ),
                      _Section(
                        titre: 'Maison',
                        child: Column(children: [
                          _Info('Modèle', p.libelleModele),
                          if (p.nombreChambresSouhaitees != null) _Info('Chambres', '${p.nombreChambresSouhaitees}'),
                          if (p.nombreSallesBainSouhaitees != null)
                            _Info('Salles de bain', '${p.nombreSallesBainSouhaitees}'),
                          if (p.surfaceConstruiteSouhaitee != null)
                            _Info('Surface construite', '${p.surfaceConstruiteSouhaitee!.toStringAsFixed(0)} m²'),
                          if ((p.descriptionModelePersonnalise ?? '').isNotEmpty)
                            _Texte(p.descriptionModelePersonnalise!),
                        ]),
                      ),
                      if (p.fichiers.isNotEmpty)
                        _Section(
                          titre: 'Pièces jointes',
                          child: Column(children: [
                            for (final f in p.fichiers) _Info(f.type.libelle, f.nomOriginal),
                          ]),
                        ),
                      if ((p.description ?? '').isNotEmpty)
                        _Section(titre: 'Votre message', child: _Texte(p.description!)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Entete extends StatelessWidget {
  final ProjetConstruction projet;
  const _Entete({required this.projet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(color: AppColors.primaryBlueAnthracite, borderRadius: AppRadius.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(projet.numeroDossier,
                    style: AppTextStyles.mono.copyWith(color: AppColors.onDarkMuted, fontSize: 12)),
              ),
              ProjetStatutPill(statut: projet.statut),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(projet.libelleModele, style: AppTextStyles.h3.copyWith(color: AppColors.white)),
          if (projet.societeNom != null)
            Text('Réalisé par ${projet.societeNom}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted)),
          if (projet.statut == StatutProjet.accepte) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.radiusRound,
                    child: LinearProgressIndicator(
                      value: projet.progression / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.white.withValues(alpha: 0.15),
                      color: AppColors.primaryOcre,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('${projet.progression} %',
                    style: AppTextStyles.cardTitle.copyWith(color: AppColors.white)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  final Widget child;
  const _Section({required this.titre, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.md - AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String libelle;
  final String valeur;
  const _Info(this.libelle, this.valeur);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(libelle, style: AppTextStyles.bodySmall)),
          Expanded(
            child: Text(valeur,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Texte extends StatelessWidget {
  final String texte;
  const _Texte(this.texte);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(texte, style: AppTextStyles.bodyMedium.copyWith(height: 1.45)),
      );
}
