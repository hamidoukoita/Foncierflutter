import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/app_assets.dart';

/// Déclinaisons du logo officiel Foncier+.
enum FoncierLogoVariante {
  /// Emblème au-dessus du mot : écrans d'accueil, connexion, splash.
  complet(AppAssets.logo),

  /// Emblème et mot côte à côte : en-têtes de dashboard.
  horizontal(AppAssets.logoHorizontal),

  /// Emblème seul : espaces réduits.
  embleme(AppAssets.logoEmbleme);

  const FoncierLogoVariante(this.asset);
  final String asset;
}

/// Logo officiel Foncier+, dimensionné par sa hauteur (les proportions sont conservées).
class FoncierLogo extends StatelessWidget {
  final FoncierLogoVariante variante;
  final double hauteur;

  const FoncierLogo(
      {super.key,
      this.variante = FoncierLogoVariante.complet,
      required this.hauteur});

  const FoncierLogo.horizontal({super.key, this.hauteur = 32})
      : variante = FoncierLogoVariante.horizontal;

  const FoncierLogo.embleme({super.key, this.hauteur = 40})
      : variante = FoncierLogoVariante.embleme;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      variante.asset,
      height: hauteur,
      fit: BoxFit.contain,
      semanticsLabel: 'Logo Foncier+',
      // Réserve la place pendant le chargement pour éviter un saut de mise en page.
      placeholderBuilder: (_) => SizedBox(height: hauteur),
    );
  }
}
