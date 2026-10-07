import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

class ProspectMesVisitesScreen extends StatelessWidget {
  const ProspectMesVisitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: EmptyStateView(
        icon: Icons.location_on_outlined,
        title: 'Mes Visites',
        message: 'Aucune visite programmée.',
      ),
    );
  }
}
