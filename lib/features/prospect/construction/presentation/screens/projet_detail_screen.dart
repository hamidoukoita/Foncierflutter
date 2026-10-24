import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/back_title_header.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/confirm_dialog.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../domain/echange_projet.dart';
import '../../domain/projet_construction.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/notifications/providers/notifications_providers.dart';
import '../../providers/construction_providers.dart';
import '../controllers/echange_controller.dart';
import '../widgets/carte_proposition.dart';
import '../widgets/decliner_proposition_sheet.dart';
import '../widgets/description_maison_chips.dart';
import '../widgets/fil_echange.dart';
import '../widgets/projet_statut.dart';
import '../widgets/section_echanges.dart';
import '../widgets/projet_suivi.dart';

/// Suivi d'un projet de construction par l'acquéreur : avancement, discussion avec la société
/// (messages et propositions à accepter ou décliner), puis le dossier envoyé.
class ProjetDetailScreen extends ConsumerStatefulWidget {
  final int projetId;
  const ProjetDetailScreen({super.key, required this.projetId});

  /// Valeur de `cibleType` des notifications qui concernent un projet de construction.
  static const String cibleNotifications = 'PROJET_CONSTRUCTION';

  @override
  ConsumerState<ProjetDetailScreen> createState() => _ProjetDetailScreenState();
}

class _ProjetDetailScreenState extends ConsumerState<ProjetDetailScreen> {
  int get projetId => widget.projetId;

  @override
  void initState() {
    super.initState();
    // Après la première image : un provider ne se modifie pas pendant la construction de l'arbre.
    WidgetsBinding.instance.addPostFrameCallback((_) => _lireNotifications());
  }

  /// Le projet est sous les yeux de l'acquéreur : ses notifications ne sont plus « nouvelles ».
  void _lireNotifications() {
    if (!mounted) return;
    ref
        .read(mesNotificationsProvider.notifier)
        .marquerLuesPourCible(ProjetDetailScreen.cibleNotifications, projetId)
        .catchError((Object e) => debugPrint('Lecture des notifications du projet impossible : $e'));
  }

  Future<void> _rafraichir(WidgetRef ref) async {
    ref.invalidate(projetDetailProvider(projetId));
    ref.invalidate(filProjetProvider(projetId));
    _lireNotifications();
    await ref.read(projetDetailProvider(projetId).future);
  }

  Future<bool> _envoyer(BuildContext context, WidgetRef ref, String texte) async {
    try {
      await ref.read(echangeProjetControllerProvider(projetId).notifier).envoyerMessage(texte);
      return true;
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
      return false;
    }
  }

  Future<void> _accepter(BuildContext context, WidgetRef ref, PropositionProjet p) async {
    final ok = await ConfirmDialog.show(
      context,
      icon: Icons.handshake_outlined,
      title: 'Accepter la proposition n°${p.numero} ?',
      message: 'Votre projet sera accepté selon ces conditions et le promoteur lancera la suite. '
          'Les autres propositions en attente seront retirées.',
      confirmLabel: 'Accepter',
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(echangeProjetControllerProvider(projetId).notifier).accepter(p.id);
      if (context.mounted) AppSnackbar.success(context, 'Proposition acceptée : votre projet est lancé.');
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
    }
  }

  Future<void> _decliner(BuildContext context, WidgetRef ref, PropositionProjet p) async {
    final reponse = await DeclinerPropositionSheet.show(context, p);
    if (reponse == null || !context.mounted) return;
    try {
      await ref.read(echangeProjetControllerProvider(projetId).notifier).decliner(p.id, reponse.commentaire);
      if (context.mounted) AppSnackbar.info(context, 'Proposition déclinée. Le promoteur peut vous en faire une autre.');
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, ErrorHandler.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(projetDetailProvider(projetId));
    final fil = ref.watch(filProjetProvider(projetId));
    final envoi = ref.watch(echangeProjetControllerProvider(projetId));
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        bottom: false,
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
                  onRefresh: () => _rafraichir(ref),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal, AppSpacing.lg, AppSpacing.pageHorizontal, AppSpacing.xl),
                    children: [
                      _Entete(projet: p),
                      const SizedBox(height: AppSpacing.md),
                      SectionEchanges(
                        societeNom: p.societeNom ?? 'le promoteur',
                        statut: p.statut,
                        propositionsEnAttente: p.enCours
                            ? (fil.valueOrNull ?? const [])
                                .whereType<PropositionFil>()
                                .where((e) => e.proposition.enAttente)
                                .length
                            : 0,
                        child: fil.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
                          ),
                          error: (e, _) => Text(ErrorHandler.messageOf(e), style: AppTextStyles.bodySmall),
                          data: (elements) => FilEchange(
                            elements: elements,
                            societeNom: p.societeNom,
                            peutRepondre: p.enCours && !envoi,
                            onAccepter: (prop) => _accepter(context, ref, prop),
                            onDecliner: (prop) => _decliner(context, ref, prop),
                          ),
                        ),
                      ),
                      _Section(titre: 'Suivi du dossier', child: ProjetSuivi(projet: p)),
                      if (p.propositionRetenue != null)
                        _Section(
                          titre: 'Accord conclu',
                          child: CarteProposition(proposition: p.propositionRetenue!, societeNom: p.societeNom),
                        ),
                      _Section(
                        titre: 'Terrain',
                        child: Column(children: [
                          _Info('Titre Foncier', p.numeroTitreFoncier),
                          _Info('Superficie totale', '${p.superficieTerrain.toStringAsFixed(0)} m²'),
                          if ((p.localisationTerrain ?? '').isNotEmpty) _Info('Localisation', p.localisationTerrain!),
                          if (p.budgetEstime != null) _Info('Budget indicatif', CurrencyFormatter.fcfa(p.budgetEstime)),
                        ]),
                      ),
                      _Section(
                        titre: 'Maison demandée',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Info('Modèle', p.libelleModele),
                            if (p.maisonSouhaitee != null) DescriptionMaisonChips(description: p.maisonSouhaitee!),
                          ],
                        ),
                      ),
                      if (p.fichiers.isNotEmpty)
                        _Section(
                          titre: 'Pièces jointes',
                          child: Column(children: [
                            for (final f in p.fichiers) _Info(f.type.libelle, f.nomOriginal),
                          ]),
                        ),
                      if ((p.description ?? '').isNotEmpty)
                        _Section(titre: 'Ce que vous avez ajouté', child: _Texte(p.description!)),
                    ],
                  ),
                ),
              ),
            ),
            if (async.valueOrNull case final p? when p.statut != StatutProjet.refuse)
              ZoneMessage(envoi: envoi, onEnvoyer: (texte) => _envoyer(context, ref, texte)),
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
