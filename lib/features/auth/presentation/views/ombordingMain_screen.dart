import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    this.onStart,
    this.onLogin,
  });

  final VoidCallback? onStart;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le fond principal est le fond clair (beige lin) de la charte
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        bottom: false, // On laisse le fond bleu déborder en bas
        child: Column(
          children: [
            // --- Section Haut : Logo, Titres et Image ---
            Expanded(
              child: Stack(
                children: [
                  // Contenu principal (texte + image)
                  Column(
                    children: [
                      const SizedBox(height: AppSpacing.xxl),

                      // LOGO
                      // Remplacez par votre vrai logo :
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        height: 80,
                        fit: BoxFit.contain,
                        semanticsLabel: 'Logo Foncier Plus',
                        placeholderBuilder: (context) => const SizedBox(
                          height: 80,
                          width: 80,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),

                    

                      const SizedBox(height: AppSpacing.xl),

                      // TITRE PRINCIPAL
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Text(
                          'Trouvez le terrain de vos projets',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // SOUS-TITRES (Mots clés)
                      Text(
                        'Parcelles • Lots • Programmes fonciers\nVillas • Terrains individuels',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              AppColors.primaryBlueAnthracite.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // IMAGE AVEC DÉCOUPE (Clipper)
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          // Utilisation du Clipper pour la forme ondulée en bas
                          child: Image.asset(
                            'assets/images/bko.png', // Votre image
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                  color: AppColors.grey300,
                                  alignment: Alignment.center,
                                  child: Image.asset(''));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Forme bleue foncée superposée au bas de l'image
                  // pour créer la transition avec la zone des boutons
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -1, // Pour éviter une ligne fine de fond
                    child: ClipPath(
                      clipper: BottomWaveClipper(),
                      child: Container(
                        height: 60, // Hauteur de la vague bleue
                        color: AppColors.primaryBlueAnthracite,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Section Bas : Boutons (Fond Bleu Anthracite) ---
            Container(
              width: double.infinity,
              color: AppColors.primaryBlueAnthracite,
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.md,
                bottom: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/ombording1'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOcre,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusRound,
                        ),
                      ),
                      child: Text(
                        'Commencer',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: onLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                    child: Text(
                      'Se connecter',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clipper pour découper le BAS de l'IMAGE en forme de vague
class OnboardingWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // On dessine le côté droit, mais on s'arrête avant le bas
    path.lineTo(size.width, size.height - 40);

    // Courbe de Bézier pour la vague (ajustez les points de contrôle selon la maquette)
    path.cubicTo(size.width * 0.75, size.height - 60, size.width * 0.25,
        size.height, 0, size.height - 20);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Clipper pour la VAGUE BLEUE FONCÉE qui fait la transition
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // On commence en bas à gauche
    path.moveTo(0, size.height);

    // On trace la même vague que l'image, mais inversée puisqu'on part du bas
    path.lineTo(0, 20); // Décalage pour correspondre à l'image

    path.cubicTo(size.width * 0.25, 0, size.width * 0.75, 40, size.width, 20);

    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
