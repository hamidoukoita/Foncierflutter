import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/providers/demarrage_provider.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';

/// Contenu d'une page de présentation.
class _Diapo {
  final String image;
  final String titre;
  final String texte;
  final Color fondIllustration;

  const _Diapo({required this.image, required this.titre, required this.texte, required this.fondIllustration});
}

const _diapos = [
  _Diapo(
    image: 'assets/images/onbording_1.png',
    titre: 'Des terrains fiables et bien situés',
    texte: 'Découvrez des parcelles et des lots viabilisés dans les meilleurs emplacements, partout au Mali.',
    fondIllustration: Color(0xFFF2ECE4),
  ),
  _Diapo(
    image: 'assets/images/onbording_2.png',
    titre: 'Réservez en toute simplicité',
    texte: 'Choisissez votre bien, faites votre réservation en ligne et suivez votre dossier en temps réel.',
    fondIllustration: Color(0xFFF2ECE4),
  ),
  _Diapo(
    image: 'assets/images/onbording_3.png',
    titre: 'Construisez votre avenir',
    texte: 'Vous avez un terrain ? Soumettez votre projet de construction et bénéficiez '
        'd\'un accompagnement personnalisé.',
    fondIllustration: AppColors.backgroundOffWhite,
  ),
];

/// Présentation de l'application en 3 pages : on avance en glissant horizontalement
/// ou avec le bouton « Suivant ».
class OnboardingDiaposPage extends ConsumerStatefulWidget {
  const OnboardingDiaposPage({super.key});

  @override
  ConsumerState<OnboardingDiaposPage> createState() => _OnboardingDiaposPageState();
}

class _OnboardingDiaposPageState extends ConsumerState<OnboardingDiaposPage> {
  final _pages = PageController();
  int _page = 0;

  bool get _derniere => _page == _diapos.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _suivant() {
    if (_derniere) {
      quitterOnboarding(context, ref, AuthRoutes.register);
    } else {
      _pages.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // « Passer » : masqué sur la dernière page, qui mène déjà à l'inscription.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: _derniere ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _derniere ? null : () => quitterOnboarding(context, ref, AuthRoutes.register),
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
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _diapos.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _PageDiapo(diapo: _diapos[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _diapos.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page ? AppColors.primaryOcre : const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _suivant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOcre,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      child: Text(
                        _derniere ? "C'est parti" : 'Suivant',
                        style: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
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

class _PageDiapo extends StatelessWidget {
  final _Diapo diapo;
  const _PageDiapo({required this.diapo});

  @override
  Widget build(BuildContext context) {
    // Défilable : sur un petit écran (ou en paysage), le texte reste lisible sans débordement.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              color: diapo.fondIllustration,
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Center(
                child: Image.asset(
                  diapo.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: AppColors.primaryBlueAnthracite.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            diapo.titre,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlueAnthracite,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            diapo.texte,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
