import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/foncier_logo.dart';

/// Écran de lancement : prend le relais du splash natif (même fond, même logo)
/// pendant la restauration de la session. Le routeur le quitte de lui-même.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Hauteur du logo natif Android (160 dp de large), pour une transition sans saut.
  static const double _hauteurLogo = 104;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _apparition =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FoncierLogo(hauteur: _hauteurLogo),
                    const SizedBox(height: AppSpacing.lg),
                    FadeTransition(
                      opacity: _apparition,
                      child: SlideTransition(
                        position:
                            Tween(begin: const Offset(0, 0.4), end: Offset.zero)
                                .animate(_apparition),
                        child: Text(
                          'Terrains titrés et viabilisés, sans litige.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _apparition,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: AppColors.primaryOcre),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('PROMOTION FONCIÈRE AGRÉÉE · MALI',
                        style: AppTextStyles.overline),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
