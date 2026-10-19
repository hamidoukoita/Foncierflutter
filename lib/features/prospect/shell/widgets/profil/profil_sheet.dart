import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_sizes.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import '../../prospect_session.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/compte/changer_mot_de_passe_dialog.dart';
import 'modifier_nom_dialog.dart';
import 'modifier_telephone_dialog.dart';
import 'profil_header.dart';
import 'profil_infos.dart';

/// Panneau « Mon profil » qui descend depuis le haut de l'écran (≈ 90 % de la hauteur).
/// Se ferme en touchant le fond, la croix, ou en le faisant glisser vers le haut.
class ProfilSheet extends ConsumerWidget {
  const ProfilSheet({super.key});

  static const double _proportionEcran = 0.9;
  static const Duration _duree = Duration(milliseconds: 380);

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer le profil',
      barrierColor: AppColors.primaryBlueAnthracite.withValues(alpha: 0.45),
      transitionDuration: _duree,
      pageBuilder: (_, __, ___) => const ProfilSheet(),
      transitionBuilder: (_, animation, __, child) {
        final courbe = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: Offset.zero)
              .animate(courbe),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    void fermer() => Navigator.of(context).pop();

    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        // Glisser vers le haut referme le panneau.
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) < -300) fermer();
        },
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            height: MediaQuery.sizeOf(context).height * _proportionEcran,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundOffWhite,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: AppShadows.floating,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    MediaQuery.paddingOf(context).top + AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                  ),
                  child: ProfilHeader(user: user, onFermer: fermer),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    child: ProfilInfos(
                      user: user,
                      onModifierNom: () => ModifierNomDialog.show(context),
                      onModifierTelephone: () =>
                          ModifierTelephoneDialog.show(context),
                      onChangerMotDePasse: () =>
                          ChangerMotDePasseDialog.show(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppActionButton(
                      label: 'Se déconnecter',
                      icon: Icons.logout_rounded,
                      variant: AppActionVariant.danger,
                      height: AppSizes.buttonLarge,
                      onPressed: () =>
                          ProspectSession.deconnecter(context, ref),
                    ),
                  ),
                ),
                // Poignée : rappelle que le panneau se referme vers le haut.
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + AppSpacing.xxs),
                  decoration: const BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: AppRadius.radiusRound),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
