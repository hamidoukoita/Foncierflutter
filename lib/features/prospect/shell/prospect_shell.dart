import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/surveillance_notifications.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/suite_vente/presentation/widgets/suite_vente_ecouteur.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/suite_vente/providers/suite_vente_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/floating_nav_bar.dart';
import 'widgets/prospect_account_menu.dart';
import 'widgets/prospect_nav_bar.dart';

/// Navigation Acquéreur : barre principale (Accueil · Cités · + · Terrains · Clés en main)
/// et rangée « Mes dossiers » (Construire · Réservations · Visites) ouverte par le « + ».
/// L'ordre des entrées suit celui des branches du routeur.
/// Relaie aussi les notifications sur le téléphone et propose les choix en attente
/// (bien réservé vendu à un autre acquéreur).
class ProspectShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ProspectShell({super.key, required this.navigationShell});

  static const List<FloatingNavItem> _principaux = [
    FloatingNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Accueil'),
    FloatingNavItem(
        icon: Icons.apartment_outlined,
        activeIcon: Icons.apartment_rounded,
        label: 'Cités'),
    FloatingNavItem(
        icon: Icons.landscape_outlined,
        activeIcon: Icons.landscape_rounded,
        label: 'Terrains'),
    FloatingNavItem(
        icon: Icons.key_outlined,
        activeIcon: Icons.key_rounded,
        label: 'Clés en main'),
  ];

  static const List<FloatingNavItem> _dossiers = [
    FloatingNavItem(
        icon: Icons.home_work_outlined,
        activeIcon: Icons.home_work_rounded,
        label: 'Construire'),
    FloatingNavItem(
        icon: Icons.bookmark_border_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: 'Réservations'),
    FloatingNavItem(
        icon: Icons.event_outlined,
        activeIcon: Icons.event_rounded,
        label: 'Visites'),
  ];

  /// Titres des onglets qui n'ont pas leur propre en-tête.
  static const Map<int, (String, String)> _entetes = {
    2: ('Terrains', 'Parcelles titrées et viabilisées'),
    3: ('Clés en main', 'Maisons prêtes à habiter'),
    4: ('Construire', 'Vos projets sur votre terrain'),
    5: ('Mes réservations', 'Suivi de vos options sur les biens'),
    6: ('Mes visites', 'Rendez-vous au siège et sur chantier'),
  };

  /// Position de « Réservations » dans la rangée « Mes dossiers ».
  static const int _indexReservations = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    final entete = _entetes[index];
    final choixEnAttente = ref.watch(reservationsAChoisirProvider).length;

    return SurveillanceNotifications(
      onNouvelles: (ref) {
        ref.invalidate(mesReservationsProvider);
        ref.invalidate(prospectDashboardProvider);
      },
      child: SuiteVenteEcouteur(
        child: Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,
          appBar: entete == null
              ? null
              : AppBar(
                  toolbarHeight: 76,
                  titleSpacing: AppSpacing.pageHorizontal,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entete.$1, style: AppTextStyles.pageTitle),
                      Text(entete.$2, style: AppTextStyles.bodySmall),
                    ],
                  ),
                  actions: const [
                    Padding(
                      padding:
                          EdgeInsets.only(right: AppSpacing.pageHorizontal),
                      child: ProspectAccountMenu(),
                    ),
                  ],
                ),
          body: navigationShell,
          bottomNavigationBar: ProspectNavBar(
            principaux: _principaux,
            dossiers: _dossiers,
            currentIndex: index,
            pastilles: {_indexReservations: choixEnAttente},
            onSelect: (i) =>
                navigationShell.goBranch(i, initialLocation: i == index),
          ),
        ),
      ),
    );
  }
}
