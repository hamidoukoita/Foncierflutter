import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/pays.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'choix_pays_sheet.dart';
import 'saisie_telephone.dart';

/// Champ numéro de téléphone : drapeau + indicatif (touchable pour changer de pays),
/// mise en forme selon le pays pendant la frappe, validation selon ses règles.
/// [maliUniquement] fige l'indicatif +223 (comptes des sociétés).
class ChampTelephone extends StatelessWidget {
  final SaisieTelephone saisie;
  final String label;
  final bool maliUniquement;

  /// Validation supplémentaire (ex. « déjà votre numéro »), après celle du format.
  final String? Function(String e164)? validationEnPlus;

  const ChampTelephone({
    super.key,
    required this.saisie,
    this.label = 'Numéro de téléphone',
    this.maliUniquement = false,
    this.validationEnPlus,
  });

  Future<void> _choisirPays(BuildContext context) async {
    final choix = await ChoixPaysSheet.afficher(context, actuel: saisie.pays.value);
    if (choix == null || choix.iso == saisie.pays.value.iso) return;
    saisie.pays.value = choix;
    // Les chiffres déjà tapés sont remis en forme selon le nouveau pays.
    saisie.texte.value = TelephoneFormatter(choix).formatEditUpdate(TextEditingValue.empty, saisie.texte.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Pays>(
      valueListenable: saisie.pays,
      builder: (context, pays, _) => AppTextField(
        label: label,
        controller: saisie.texte,
        keyboardType: TextInputType.phone,
        hintText: pays.exemple,
        prefixIcon: _Indicatif(pays: pays, onTap: maliUniquement ? null : () => _choisirPays(context)),
        inputFormatters: [TelephoneFormatter(pays)],
        validator: (v) {
          final erreur = saisie.valider(v);
          if (erreur != null) return erreur;
          return validationEnPlus?.call(saisie.e164);
        },
      ),
    );
  }
}

/// Drapeau et indicatif en tête du champ ; une flèche signale qu'on peut changer de pays.
class _Indicatif extends StatelessWidget {
  final Pays pays;
  final VoidCallback? onTap;

  const _Indicatif({required this.pays, this.onTap});

  @override
  Widget build(BuildContext context) {
    final contenu = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSpacing.gapSm,
        Text(pays.drapeau, style: const TextStyle(fontSize: 18)),
        AppSpacing.gapXs,
        Text(
          '+${pays.indicatif}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryBlueAnthracite,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onTap != null) const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
        Container(
          height: 20,
          width: 1,
          margin: EdgeInsets.only(left: onTap == null ? AppSpacing.sm : 0, right: AppSpacing.sm + AppSpacing.xxs),
          color: AppColors.borderLight,
        ),
      ],
    );
    if (onTap == null) return contenu;
    return Semantics(
      button: true,
      label: 'Pays : ${pays.nom}. Changer de pays',
      child: InkWell(onTap: onTap, borderRadius: AppRadius.radiusMd, child: contenu),
    );
  }
}
