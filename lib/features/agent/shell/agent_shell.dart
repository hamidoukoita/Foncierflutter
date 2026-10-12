import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

class AgentShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AgentShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        child: SafeArea(
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.white,
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOcre,
                  );
                }
                return AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey500,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                    color: AppColors.primaryOcre,
                    size: 24,
                  );
                }
                return const IconThemeData(
                  color: AppColors.grey500,
                  size: 24,
                );
              }),
            ),
            child: NavigationBar(
              height: 64,
              elevation: 0,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Vue d’ensemble',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today_rounded),
                  label: 'Visites',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
