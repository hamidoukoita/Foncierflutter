import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import '../domain/visite_statut.dart';

class VisiteStatutBadge extends StatelessWidget {
  final VisiteStatut statut;

  const VisiteStatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    return SoftBadge(
      label: statut.libelle,
      background: statut.fond,
      foreground: statut.couleur,
      icon: statut.icone,
    );
  }
}
