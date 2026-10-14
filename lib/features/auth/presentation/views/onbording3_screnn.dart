import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/providers/demarrage_provider.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

class OnboardingThreePage extends ConsumerWidget {
  const OnboardingThreePage({
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
              const SizedBox(height: AppSpacing.lg),

              // Zone illustration (fond beige/lin arrondi)
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: AppColors.backgroundOffWhite,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    // Remplace par ton image ici :
                    child: Image.asset(
                      'assets/images/onbording_3.png',
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
                'Construisez votre avenir',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlueAnthracite,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 4. Description
              Text(
                'Vous avez un terrain ? Soumettez votre projet de construction et bénéficiez d\'un accompagnement personnalisé.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.black,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // 5. Indicateur de progression (3e point actif)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(isActive: false),
                    const SizedBox(width: 8),
                    _buildDot(isActive: false),
                    const SizedBox(width: 8),
                    _buildDot(isActive: true),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 6. Bouton CTA "C'est parti"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () =>
                      quitterOnboarding(context, ref, AuthRoutes.register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOcre,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  child: Text(
                    "C'est parti",
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
        color: isActive ? AppColors.primaryOcre : AppColors.backgroundOffWhite,
        shape: BoxShape.circle,
      ),
    );
  }
}
