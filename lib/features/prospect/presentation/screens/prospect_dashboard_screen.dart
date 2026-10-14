import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/domain/annonce_accueil.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/domain/suivi_acquereur.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/accueil_feedback.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/accueil_header.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/annonce_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/construction_callout.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/hero_banner.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/mon_suivi_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/accueil/presentation/widgets/zones_strip.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/zones_exploration.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/section_header.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/construction_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/presentation/widgets/projet_card.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/providers/construction_providers.dart';

/// Accueil Acquéreur : suivi personnel, exploration par zone, annonces récentes.
class ProspectDashboardScreen extends ConsumerWidget {
  const ProspectDashboardScreen({super.key});

  /// Projets de construction affichés sur l'accueil ; les autres sont dans « Tout voir ».
  static const int _projetsApercu = 2;

  static const EdgeInsets _marges =
      EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal);

  Future<void> _rafraichir(WidgetRef ref) async {
    ref.invalidate(mesVisitesProvider);
    ref.invalidate(mesProjetsProvider);
    await ref.read(prospectDashboardProvider.notifier).refresh();
  }

  void _ouvrir(BuildContext context, AnnonceAccueil annonce) {
    final programme = annonce.programme;
    if (programme != null) {
      context.push('/prospect/programmes/${programme.id}');
    } else {
      context.push('/prospect/parcelles/${annonce.bien!.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(prospectDashboardProvider);
    final state = asyncState.valueOrNull;
    final user = ref.watch(authProvider).user;
    final reservations = state?.mesReservations ?? const <ReservationModel>[];
    final visites =
        ref.watch(mesVisitesProvider).valueOrNull ?? const <RendezVousModel>[];
    final programmes = state?.programmes ?? const [];
    final projets = ref.watch(mesProjetsProvider).valueOrNull ?? const [];

    final suivi = SuiviAcquereur.depuis(reservations, visites, DateTime.now());
    final zones = ZonesExploration.depuisProgrammes(programmes);
    final annonces =
        AnnoncesAccueil.recentes(programmes, state?.catalogue ?? const []);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: AppColors.backgroundOffWhite),
      child: Scaffold(
        backgroundColor: AppColors.backgroundOffWhite,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => _rafraichir(ref),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _bloc(
                  AccueilHeader(user: user),
                  haut: AppSpacing.md,
                ),
                _bloc(
                  MonSuiviCard(
                    suivi: suivi,
                    onReservations: () => context.go('/prospect/reservations'),
                    onVisites: () => context.go('/prospect/visites'),
                    onExplorer: () => context.go('/prospect/cites'),
                  ),
                ),
                if (projets.isNotEmpty) ...[
                  _bloc(SectionHeader(
                    title: 'Mes projets de construction',
                    subtitle: 'L’avancement de vos dossiers',
                    actionLabel: 'Tout voir',
                    onAction: () => context.go(ConstructionRoutes.liste),
                  )),
                  for (final projet in projets.take(_projetsApercu))
                    _bloc(
                      ProjetCard(
                        projet: projet,
                        onTap: () => context.push(ConstructionRoutes.detail(projet.id)),
                      ),
                      haut: AppSpacing.md - AppSpacing.xs,
                    ),
                ],
                if (zones.isNotEmpty) ...[
                  _bloc(const SectionHeader(
                    title: 'Explorer par zone',
                    subtitle: 'Les quartiers où les promoteurs commercialisent',
                  )),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: ZonesStrip(
                        zones: zones,
                        onZone: (zone) => context.go(Uri(
                            path: '/prospect/cites',
                            queryParameters: {'zone': zone}).toString()),
                      ),
                    ),
                  ),
                ],
                _bloc(
                    HeroBanner(onExplore: () => context.go('/prospect/cites'))),
                _bloc(ConstructionCallout(
                  onTap: () => context.push(ConstructionRoutes.nouveau),
                )),
                _bloc(SectionHeader(
                  title: 'Annonces récentes',
                  actionLabel: 'Tout voir',
                  onAction: () => context.go('/prospect/cites'),
                )),
                ..._annonces(context, ref, asyncState, annonces),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bloc horizontal standard de l'accueil.
  Widget _bloc(Widget child, {double haut = AppSpacing.lg}) => SliverPadding(
        padding: _marges.copyWith(top: haut),
        sliver: SliverToBoxAdapter(child: child),
      );

  List<Widget> _annonces(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ProspectDashboardState> asyncState,
    List<AnnonceAccueil> annonces,
  ) {
    if (asyncState.hasError) {
      return [
        _bloc(
            AccueilFeedback(
              icon: Icons.cloud_off_outlined,
              title: 'Impossible de charger les annonces',
              message: 'Vérifiez votre connexion puis réessayez.',
              actionLabel: 'Réessayer',
              onAction: () => _rafraichir(ref),
            ),
            haut: AppSpacing.md),
      ];
    }
    if (asyncState.isLoading && asyncState.valueOrNull == null) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }
    if (annonces.isEmpty) {
      return [
        _bloc(
            AccueilFeedback(
              icon: Icons.location_searching_rounded,
              title: 'Aucune annonce pour le moment',
              message:
                  'Les biens publiés apparaîtront ici dès qu’ils seront disponibles.',
              actionLabel: 'Actualiser',
              onAction: () => _rafraichir(ref),
            ),
            haut: AppSpacing.md),
      ];
    }
    return [
      SliverPadding(
        padding: _marges.copyWith(top: AppSpacing.md),
        sliver: SliverList.separated(
          itemCount: annonces.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md - AppSpacing.xs),
          itemBuilder: (context, i) => AnnonceCard(
            annonce: annonces[i],
            onTap: () => _ouvrir(context, annonces[i]),
          ),
        ),
      ),
    ];
  }
}
