import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

/// Navigation Acquéreur alignée sur la maquette Figma.
class ProspectShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ProspectShell({super.key, required this.navigationShell});

  static const _titles = [
    'Accueil',
    'Cités & Plan',
    'Réservations',
    'Parcelles',
    'Mes Visites',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final index = navigationShell.currentIndex;
    final initials = _initials(user?.prenom, user?.nom);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      // Accueil & Cités & Plan : titre dans le body (Figma) — pas de doublon AppBar.
      appBar: (index == 0)
          ? null
          : AppBar(
              titleSpacing: 20,
              // Index 1 = Cités & Plan : pas de titre (déjà dans la page)
              title: index == 1
                  ? const SizedBox.shrink()
                  : Text(
                      _titles[index.clamp(0, _titles.length - 1)],
                      style: AppTextStyles.h3,
                    ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: PopupMenuButton<String>(
                    tooltip: 'Mon compte',
                    offset: const Offset(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusLg,
                    ),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Mon compte',
                              style: AppTextStyles.h4,
                            ),
                            if (user?.telephone.isNotEmpty == true)
                              Text(
                                user!.telephone,
                                style: AppTextStyles.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                size: 18, color: AppColors.errorRed),
                            SizedBox(width: 8),
                            Text('Se déconnecter'),
                          ],
                        ),
                      ),
                    ],
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.primaryBlueAnthracite,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.borderLight),
              ),
            ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) {
              navigationShell.goBranch(i, initialLocation: i == index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.apartment_outlined),
                selectedIcon: Icon(Icons.apartment_rounded),
                label: 'Cités & Plan',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Réservations',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Parcelles',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event_rounded),
                label: 'Mes Visites',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String? prenom, String? nom) {
    final a = (prenom != null && prenom.isNotEmpty) ? prenom[0] : '';
    final b = (nom != null && nom.isNotEmpty) ? nom[0] : '';
    final value = '$a$b'.toUpperCase();
    return value.isEmpty ? 'A' : value;
  }
}
