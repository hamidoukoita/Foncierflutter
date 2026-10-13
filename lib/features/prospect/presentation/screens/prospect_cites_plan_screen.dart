import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/views/catalogue_screen.dart';

/// Onglet « Cités & Plan » : catalogue des programmes fonciers,
/// éventuellement pré-filtré sur une zone (depuis l'accueil).
class ProspectCitesPlanScreen extends StatelessWidget {
  final String? zone;

  const ProspectCitesPlanScreen({super.key, this.zone});

  @override
  Widget build(BuildContext context) => CatalogueScreen(zoneInitiale: zone);
}
