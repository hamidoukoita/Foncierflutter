import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/floating_nav_bar.dart';
import 'widgets/prospect_account_menu.dart';

/// Navigation Acquéreur : barre flottante + en-tête des onglets secondaires.
class ProspectShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ProspectShell({super.key, required this.navigationShell});

  static const List<FloatingNavItem> _items = [
    FloatingNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Accueil'),
    FloatingNavItem(
        icon: Icons.apartment_outlined,
        activeIcon: Icons.apartment_rounded,
        label: 'Cités'),
    FloatingNavItem(
        icon: Icons.bookmark_border_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: 'Réservations'),
    FloatingNavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'Parcelles'),
    FloatingNavItem(
        icon: Icons.event_outlined,
        activeIcon: Icons.event_rounded,
        label: 'Visites'),
  ];

  /// Titres des onglets qui n'ont pas leur propre en-tête.
  static const Map<int, (String, String)> _entetes = {
    2: ('Mes réservations', 'Suivi de vos options sur les biens'),
    3: ('Parcelles', 'Terrains titrés et viabilisés'),
    4: ('Mes visites', 'Rendez-vous au siège et sur chantier'),
  };

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    final entete = _entetes[index];

    return Scaffold(
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
                  padding: EdgeInsets.only(right: AppSpacing.pageHorizontal),
                  child: ProspectAccountMenu(),
                ),
              ],
            ),
      body: navigationShell,
      bottomNavigationBar: FloatingNavBar(
        items: _items,
        currentIndex: index,
        onSelect: (i) =>
            navigationShell.goBranch(i, initialLocation: i == index),
      ),
    );
  }
}
