import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_sizes.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/floating_nav_bar.dart';

/// Barre de navigation de l'acquéreur, sur deux étages :
/// - devant : les onglets principaux de part et d'autre d'un bouton « + » central ;
/// - derrière : « Mes dossiers », une rangée qui glisse vers le haut au toucher du « + »,
///   comme une seconde barre posée derrière la première.
/// Les index 0..principaux-1 désignent la barre avant, les suivants la rangée arrière.
class ProspectNavBar extends StatefulWidget {
  final List<FloatingNavItem> principaux;
  final List<FloatingNavItem> dossiers;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const ProspectNavBar({
    super.key,
    required this.principaux,
    required this.dossiers,
    required this.currentIndex,
    required this.onSelect,
  });

  static const Duration duree = Duration(milliseconds: 340);
  static const Curve courbe = Curves.easeOutCubic;

  static const double _hauteurAvant = 70;
  static const double _hauteurArriere = 58;
  /// Partie de la rangée arrière cachée sous la barre avant.
  static const double _recouvrement = 16;

  @override
  State<ProspectNavBar> createState() => _ProspectNavBarState();
}

class _ProspectNavBarState extends State<ProspectNavBar> {
  late bool _ouvert = _surUnDossier;

  bool get _surUnDossier => widget.currentIndex >= widget.principaux.length;

  @override
  void didUpdateWidget(covariant ProspectNavBar ancien) {
    super.didUpdateWidget(ancien);
    // Arrivée sur un dossier (lien depuis l'accueil…) : la rangée s'ouvre pour situer la page.
    if (_surUnDossier && ancien.currentIndex != widget.currentIndex) _ouvert = true;
  }

  void _basculer() => setState(() => _ouvert = !_ouvert);

  @override
  Widget build(BuildContext context) {
    const avant = ProspectNavBar._hauteurAvant;
    const arriere = ProspectNavBar._hauteurArriere;
    const recouvrement = ProspectNavBar._recouvrement;
    final n = widget.principaux.length;
    final moitie = n ~/ 2;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSizes.navBarMargin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.navBarMargin),
        child: AnimatedContainer(
          duration: ProspectNavBar.duree,
          curve: ProspectNavBar.courbe,
          height: _ouvert ? avant + arriere - recouvrement : avant,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Rangée arrière « Mes dossiers ».
              AnimatedPositioned(
                duration: ProspectNavBar.duree,
                curve: ProspectNavBar.courbe,
                left: AppSpacing.md - AppSpacing.xs,
                right: AppSpacing.md - AppSpacing.xs,
                bottom: _ouvert ? avant - recouvrement : avant - arriere,
                height: arriere,
                child: IgnorePointer(
                  ignoring: !_ouvert,
                  child: AnimatedOpacity(
                    duration: ProspectNavBar.duree,
                    curve: ProspectNavBar.courbe,
                    opacity: _ouvert ? 1 : 0,
                    child: _RangeeDossiers(
                      items: widget.dossiers,
                      actif: widget.currentIndex - n,
                      onSelect: (i) => widget.onSelect(n + i),
                    ),
                  ),
                ),
              ),
              // Barre avant.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: avant,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadius.radiusXxl,
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: AppShadows.floating,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < moitie; i++) _entreeAvant(i),
                      _BoutonDossiers(ouvert: _ouvert, surUnDossier: _surUnDossier, onTap: _basculer),
                      for (var i = moitie; i < n; i++) _entreeAvant(i),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entreeAvant(int i) => Expanded(
        child: _EntreeAvant(
          item: widget.principaux[i],
          active: widget.currentIndex == i,
          onTap: () => widget.onSelect(i),
        ),
      );
}

/// Onglet de la barre avant : icône et libellé, pastille ocre douce quand il est actif.
class _EntreeAvant extends StatelessWidget {
  final FloatingNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _EntreeAvant({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final couleur = active ? AppColors.primaryOcreDark : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: ProspectNavBar.duree,
            curve: ProspectNavBar.courbe,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs + AppSpacing.xxs),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryOcreSoft : AppColors.transparent,
              borderRadius: AppRadius.radiusLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(active ? item.activeIcon : item.icon, size: 22, color: couleur),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10.5,
                    color: couleur,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton « + » central : ouvre ou referme la rangée « Mes dossiers ».
class _BoutonDossiers extends StatelessWidget {
  final bool ouvert;
  final bool surUnDossier;
  final VoidCallback onTap;

  const _BoutonDossiers({required this.ouvert, required this.surUnDossier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Semantics(
        button: true,
        label: ouvert ? 'Fermer mes dossiers' : 'Mes dossiers',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: ProspectNavBar.duree,
            curve: ProspectNavBar.courbe,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: ouvert ? AppGradients.navy : AppGradients.cta,
              shape: BoxShape.circle,
              boxShadow: AppShadows.cta,
              border: Border.all(
                color: surUnDossier && !ouvert ? AppColors.primaryBlueAnthracite : AppColors.white,
                width: 3,
              ),
            ),
            child: AnimatedRotation(
              duration: ProspectNavBar.duree,
              curve: ProspectNavBar.courbe,
              turns: ouvert ? 0.125 : 0,
              child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rangée arrière : onglets texte, le dossier ouvert ressort sur une pastille blanche.
class _RangeeDossiers extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int actif;
  final ValueChanged<int> onSelect;

  const _RangeeDossiers({required this.items, required this.actif, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs + AppSpacing.xxs, AppSpacing.xs + AppSpacing.xxs, AppSpacing.xs + AppSpacing.xxs, ProspectNavBar._recouvrement),
      decoration: BoxDecoration(
        color: AppColors.placeholderSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: ProspectNavBar.duree,
                  curve: ProspectNavBar.courbe,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: i == actif ? AppColors.white : AppColors.transparent,
                    borderRadius: AppRadius.radiusLg,
                    boxShadow: i == actif ? AppShadows.soft : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(i == actif ? items[i].activeIcon : items[i].icon,
                          size: 17, color: i == actif ? AppColors.primaryOcre : AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          items[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: i == actif ? AppColors.primaryBlueAnthracite : AppColors.textSecondary,
                            fontWeight: i == actif ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
