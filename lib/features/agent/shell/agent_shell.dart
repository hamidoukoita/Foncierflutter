import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/floating_nav_bar.dart';

/// Navigation de l'agent collaborateur : barre flottante à deux onglets.
class AgentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AgentShell({super.key, required this.navigationShell});

  static const List<FloatingNavItem> _items = [
    FloatingNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Vue d’ensemble',
    ),
    FloatingNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Visites',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: navigationShell,
      bottomNavigationBar: FloatingNavBar(
        items: _items,
        currentIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
