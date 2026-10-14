import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/providers/demarrage_provider.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class OnboardingTwoPage extends ConsumerWidget {
  const OnboardingTwoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bouton "Passer" en haut à droite
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      quitterOnboarding(context, ref, AuthRoutes.register),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlueAnthracite,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Passer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlueAnthracite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. Conteneur arrondi pour l'illustration
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF2ECE4), // Fond lin doux de la maquette
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: Image.asset(
                      'assets/images/onbording_2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: AppColors.primaryBlueAnthracite
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 3. Titre principal
              Text(
                'Réservez en toute simplicité',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlueAnthracite,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 4. Description
              Text(
                'Choisissez votre bien, faites votre réservation en ligne et suivez votre dossier en temps réel.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // 5. Indicateur de progression (3 points avec le 2e actif)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(isActive: false),
                    const SizedBox(width: 8),
                    _buildDot(isActive: true),
                    const SizedBox(width: 8),
                    _buildDot(isActive: false),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 6. Bouton CTA "Suivant"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.push(AuthRoutes.onboarding3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOcre,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  child: Text(
                    'Suivant',
                    style: AppTextStyles.buttonText.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryOcre : const Color(0xFFD1D5DB),
        shape: BoxShape.circle,
      ),
    );
  }
}
