import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/floating_nav_bar.dart';
import 'widgets/prospect_account_menu.dart';
import 'widgets/prospect_nav_bar.dart';

/// Navigation Acquéreur : barre principale (Accueil · Cités · + · Terrains · Clés en main)
/// et rangée « Mes dossiers » (Construire · Réservations · Visites) ouverte par le « + ».
/// L'ordre des entrées suit celui des branches du routeur.
class ProspectShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ProspectShell({super.key, required this.navigationShell});

  static const List<FloatingNavItem> _principaux = [
    FloatingNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil'),
    FloatingNavItem(icon: Icons.apartment_outlined, activeIcon: Icons.apartment_rounded, label: 'Cités'),
    FloatingNavItem(icon: Icons.landscape_outlined, activeIcon: Icons.landscape_rounded, label: 'Terrains'),
    FloatingNavItem(icon: Icons.key_outlined, activeIcon: Icons.key_rounded, label: 'Clés en main'),
  ];

  static const List<FloatingNavItem> _dossiers = [
    FloatingNavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work_rounded, label: 'Construire'),
    FloatingNavItem(icon: Icons.bookmark_border_rounded, activeIcon: Icons.bookmark_rounded, label: 'Réservations'),
    FloatingNavItem(icon: Icons.event_outlined, activeIcon: Icons.event_rounded, label: 'Visites'),
  ];

  /// Titres des onglets qui n'ont pas leur propre en-tête.
  static const Map<int, (String, String)> _entetes = {
    2: ('Terrains', 'Parcelles titrées et viabilisées'),
    3: ('Clés en main', 'Maisons prêtes à habiter'),
    4: ('Construire', 'Vos projets sur votre terrain'),
    5: ('Mes réservations', 'Suivi de vos options sur les biens'),
    6: ('Mes visites', 'Rendez-vous au siège et sur chantier'),
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
      bottomNavigationBar: ProspectNavBar(
        principaux: _principaux,
        dossiers: _dossiers,
        currentIndex: index,
        onSelect: (i) => navigationShell.goBranch(i, initialLocation: i == index),
      ),
    );
  }
}
