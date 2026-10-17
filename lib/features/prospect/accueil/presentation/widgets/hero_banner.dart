import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Bannière d'accueil : promesse « zéro litige » et accès aux cités.
class HeroBanner extends StatelessWidget {
  final VoidCallback onExplore;

  const HeroBanner({super.key, required this.onExplore});

  // Illustration décorative de la bannière, indépendante des données métier.
  static const String _imageUrl =
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.floating,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.navy)),
          Image.network(
            _imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const SizedBox.shrink(),
          ),
          // Voile dégradé : lisibilité du texte à gauche, photo visible à droite.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primaryBlueAnthracite.withValues(alpha: 0.92),
                  AppColors.primaryBlueAnthracite.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        size: 14, color: AppColors.primaryOcreLight),
                    const SizedBox(width: AppSpacing.xs),
                    Text('ZÉRO LITIGE GARANTI',
                        style: AppTextStyles.overline
                            .copyWith(color: AppColors.primaryOcreLight)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Trouvez votre terrain idéal\nchez un promoteur agréé',
                  style: AppTextStyles.heroTitle.copyWith(fontSize: 19),
                ),
                const Spacer(),
                _ExplorerPill(onTap: onExplore),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplorerPill extends StatelessWidget {
  final VoidCallback onTap;
  const _ExplorerPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.cta,
        borderRadius: AppRadius.radiusRound,
        boxShadow: AppShadows.cta,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusRound,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Explorer les terrains',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.w700)),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
