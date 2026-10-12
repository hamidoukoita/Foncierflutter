import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class OnboardingOnePage extends StatelessWidget {
  const OnboardingOnePage({
    super.key
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: ()=>context.push("/register"),
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

              // 2. Zone illustration (fond lin arrondi)
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2ECE4),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    // Remplace par ton image ici :
                    child: Image.asset(
                      'assets/images/onbording_1.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: AppColors.primaryBlueAnthracite.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 3. Titre principal
              Text(
                'Des terrains fiables et bien situés',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlueAnthracite,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 4. Description
              Text(
                'Découvrez des parcelles et des lots viabilisés dans les meilleurs emplacements, partout au Mali.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // 5. Indicateur de progression (1er point actif)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(isActive: true),
                    const SizedBox(width: 8),
                    _buildDot(isActive: false),
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
                  onPressed: ()=>context.push("/ombording2"),
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
