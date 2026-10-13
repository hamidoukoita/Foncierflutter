import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Entrée de la barre de navigation.
class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Barre de navigation flottante arrondie.
/// Une pastille ocre unique glisse d'un onglet à l'autre ; l'onglet actif
/// s'élargit pour afficher son libellé, les autres restent en icône seule.
class FloatingNavBar extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  /// Durée et courbe communes : pastille, largeurs et libellés bougent ensemble.
  static const Duration duree = Duration(milliseconds: 380);
  static const Curve courbe = Curves.easeInOutCubic;

  /// L'onglet actif occupe deux parts, les autres une seule.
  static const int _partsActif = 2;

  static const double _hauteurPastille = 44;
  static const double _margeInterne = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSizes.navBarMargin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.navBarMargin),
        child: Container(
          height: AppSizes.navBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: _margeInterne),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.radiusXxl,
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppShadows.floating,
          ),
          child: LayoutBuilder(
            builder: (context, contraintes) {
              final part = contraintes.maxWidth / (items.length - 1 + _partsActif);
              double largeur(int i) => i == currentIndex ? part * _partsActif : part;
              final gauchePastille = part * currentIndex;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Pastille qui glisse vers l'onglet sélectionné.
                  AnimatedPositioned(
                    duration: duree,
                    curve: courbe,
                    left: gauchePastille + AppSpacing.xs,
                    width: part * _partsActif - AppSpacing.sm,
                    top: (AppSizes.navBarHeight - _hauteurPastille) / 2 - 1,
                    height: _hauteurPastille,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.cta,
                        borderRadius: AppRadius.radiusXl,
                        boxShadow: AppShadows.cta,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        AnimatedContainer(
                          duration: duree,
                          curve: courbe,
                          width: largeur(i),
                          child: _NavEntry(
                            item: items[i],
                            active: i == currentIndex,
                            onTap: () => onSelect(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavEntry extends StatelessWidget {
  final FloatingNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavEntry({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusXl,
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        child: SizedBox(
          height: AppSizes.navBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // L'icône change de couleur au passage de la pastille.
              TweenAnimationBuilder<Color?>(
                duration: FloatingNavBar.duree,
                curve: FloatingNavBar.courbe,
                tween: ColorTween(end: active ? AppColors.white : AppColors.textSecondary),
                builder: (_, couleur, __) => Icon(
                  active ? item.activeIcon : item.icon,
                  size: 22,
                  color: couleur,
                ),
              ),
              // Le libellé se déploie et apparaît en fondu.
              Flexible(
                child: AnimatedSize(
                  duration: FloatingNavBar.duree,
                  curve: FloatingNavBar.courbe,
                  child: AnimatedOpacity(
                    duration: FloatingNavBar.duree,
                    curve: FloatingNavBar.courbe,
                    opacity: active ? 1 : 0,
                    child: active
                        ? Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xs + AppSpacing.xxs),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
