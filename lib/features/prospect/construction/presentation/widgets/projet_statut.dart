import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';
import '../../domain/projet_construction.dart';

/// Libellé et couleur d'un statut de projet, communs à la liste, au détail et à l'accueil.
extension PresentationStatutProjet on StatutProjet {
  String get libelle => switch (this) {
        StatutProjet.enEtude => 'En étude',
        StatutProjet.accepte => 'Accepté',
        StatutProjet.refuse => 'Refusé',
      };

  Color get couleur => switch (this) {
        StatutProjet.enEtude => AppColors.warningAmber,
        StatutProjet.accepte => AppColors.successGreen,
        StatutProjet.refuse => AppColors.errorRed,
      };
}

class ProjetStatutPill extends StatelessWidget {
  final StatutProjet statut;
  const ProjetStatutPill({super.key, required this.statut});

  @override
  Widget build(BuildContext context) => StatusPill(label: statut.libelle, color: statut.couleur);
}
