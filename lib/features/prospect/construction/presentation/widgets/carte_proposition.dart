import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';
import '../../domain/echange_projet.dart';
import 'description_maison_chips.dart';

extension _PresentationStatutProposition on StatutProposition {
  Color get couleur => switch (this) {
        StatutProposition.enAttente => AppColors.primaryOcre,
        StatutProposition.acceptee => AppColors.successGreen,
        StatutProposition.refusee => AppColors.errorRed,
        StatutProposition.caduque => AppColors.textMuted,
      };
}

/// Proposition de la société. Tant qu'elle attend une réponse, l'acquéreur peut l'accepter ou la décliner.
class CarteProposition extends StatelessWidget {
  final PropositionProjet proposition;
  final String? societeNom;

  /// Null : la carte est seulement affichée (réponse déjà donnée, accord conclu…).
  final VoidCallback? onAccepter;
  final VoidCallback? onDecliner;

  const CarteProposition({
    super.key,
    required this.proposition,
    this.societeNom,
    this.onAccepter,
    this.onDecliner,
  });

  @override
  Widget build(BuildContext context) {
    final p = proposition;
    final couleur = p.statut.couleur;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: p.enAttente ? AppColors.primaryOcre : AppColors.borderLight, width: p.enAttente ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROPOSITION N°${p.numero}${societeNom == null ? '' : ' · $societeNom'}',
                          style: AppTextStyles.overline.copyWith(color: AppColors.primaryOcre)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(p.titre, style: AppTextStyles.cardTitle),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.12),
                    borderRadius: AppRadius.radiusRound,
                  ),
                  child: Text(p.statut.libelle,
                      style: AppTextStyles.bodySmall.copyWith(color: couleur, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.modeleLibelle != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.home_outlined, size: 18, color: AppColors.primaryOcre),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: Text('Modèle : ${p.modeleLibelle}', style: AppTextStyles.bodyMedium)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (p.maison != null) DescriptionMaisonChips(description: p.maison!),
                if (p.prixEstime != null || p.delaiMois != null) ...[
                  const SizedBox(height: AppSpacing.md - AppSpacing.xs),
                  Row(
                    children: [
                      if (p.prixEstime != null)
                        Expanded(child: _Chiffre(libelle: 'Prix estimé', valeur: CurrencyFormatter.fcfa(p.prixEstime))),
                      if (p.prixEstime != null && p.delaiMois != null) const SizedBox(width: AppSpacing.sm),
                      if (p.delaiMois != null)
                        Expanded(child: _Chiffre(libelle: 'Délai estimé', valeur: '${p.delaiMois} mois')),
                    ],
                  ),
                ],
                if ((p.commentaire ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md - AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundOffWhite,
                      border: Border(left: BorderSide(color: AppColors.primaryOcre, width: 3)),
                    ),
                    child: Text(p.commentaire!, style: AppTextStyles.bodyMedium.copyWith(height: 1.45)),
                  ),
                ],
                for (final plan in p.plans)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.architecture_rounded, size: 18, color: AppColors.primaryOcre),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text('Plan joint : ${plan.nomOriginal}',
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall),
                        ),
                      ],
                    ),
                  ),
                if (p.statut == StatutProposition.refusee && (p.reponseAcquereur ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('Votre réponse : ${p.reponseAcquereur}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.errorRed)),
                ],
                if (p.dateProposition != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('Reçue le ${DateFormatter.dateLongue(p.dateProposition!)}', style: AppTextStyles.bodySmall),
                ],
                if (onAccepter != null && onDecliner != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: PrimaryButton(text: 'Décliner', isSecondary: true, onPressed: onDecliner)),
                      const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                      Expanded(child: PrimaryButton(text: 'Accepter', icon: Icons.check_rounded, onPressed: onAccepter)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  final String libelle;
  final String valeur;
  const _Chiffre({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
      decoration: const BoxDecoration(color: AppColors.backgroundOffWhite, borderRadius: AppRadius.radiusMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(libelle.toUpperCase(), style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.xxs),
          Text(valeur, style: AppTextStyles.cardTitle.copyWith(color: AppColors.primaryBlueAnthracite)),
        ],
      ),
    );
  }
}
