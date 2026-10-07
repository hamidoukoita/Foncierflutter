import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

class ProspectReservationsScreen extends StatelessWidget {
  const ProspectReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: EmptyStateView(
        icon: Icons.bookmark_outline,
        title: 'Réservations',
        message: 'Aucune réservation en cours.',
      ),
    );
  }
}
