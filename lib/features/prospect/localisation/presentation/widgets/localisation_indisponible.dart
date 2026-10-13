import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../domain/lieu_carte.dart';
import 'localisation_panel.dart';
import 'map_top_bar.dart';

/// Aucune position exploitable : message clair, commodités toujours listées.
class LocalisationIndisponible extends StatelessWidget {
  final LieuCarte lieu;

  const LocalisationIndisponible({super.key, required this.lieu});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: MapTopBar(titre: lieu.titre, sousTitre: lieu.sousTitre),
          ),
        ),
        const Expanded(
          child: EmptyStateView(
            icon: Icons.location_off_outlined,
            title: 'Localisation non renseignée',
            message:
                'Le promoteur n\'a pas encore communiqué les coordonnées GPS de ce bien.',
          ),
        ),
        LocalisationPanel(lieu: lieu),
      ],
    );
  }
}
