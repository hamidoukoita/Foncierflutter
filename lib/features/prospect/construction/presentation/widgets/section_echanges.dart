import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../../domain/projet_construction.dart';

/// Bloc de la discussion avec la société, mis en avant juste sous l'en-tête du projet :
/// bandeau ocre, nombre de propositions qui attendent une réponse, fond chaud.
class SectionEchanges extends StatefulWidget {
  final String societeNom;
  final StatutProjet statut;

  /// Propositions de la société encore sans réponse de l'acquéreur.
  final int propositionsEnAttente;
  final Widget child;

  /// Part maximale de la hauteur d'écran occupée par la discussion.
  static const double hauteurMax = 0.55;

  const SectionEchanges({
    super.key,
    required this.societeNom,
    required this.statut,
    required this.propositionsEnAttente,
    required this.child,
  });

  @override
  State<SectionEchanges> createState() => _SectionEchangesState();
}

class _SectionEchangesState extends State<SectionEchanges> {
  final _defilement = ScrollController();

  @override
  void dispose() {
    _defilement.dispose();
    super.dispose();
  }

  String get _sousTitre {
    final enAttente = widget.propositionsEnAttente;
    if (enAttente > 0) {
      return enAttente > 1
          ? '$enAttente propositions attendent votre réponse'
          : 'Une proposition attend votre réponse';
    }
    return switch (widget.statut) {
      StatutProjet.enEtude => 'Le promoteur étudie votre dossier',
      StatutProjet.enDiscussion => 'Posez vos questions, répondez aux propositions',
      StatutProjet.accepte => 'Restez en contact pendant les travaux',
      StatutProjet.refuse => 'La discussion est close',
    };
  }

  @override
  Widget build(BuildContext context) {
    final attente = widget.propositionsEnAttente > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryOcreSoft.withValues(alpha: 0.45),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.primaryOcre, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOcre.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
            decoration: const BoxDecoration(gradient: AppGradients.cta),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_rounded, color: AppColors.white, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Échanges avec ${widget.societeNom}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(color: AppColors.white)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(_sousTitre,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.92),
                            fontWeight: attente ? FontWeight.w800 : FontWeight.w500,
                          )),
                    ],
                  ),
                ),
                if (attente)
                  Container(
                    margin: const EdgeInsets.only(left: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: const BoxDecoration(color: AppColors.white, borderRadius: AppRadius.radiusRound),
                    child: Text('${widget.propositionsEnAttente}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primaryOcreDark, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ),
          // Hauteur limitée et défilement propre au bloc : il s'ouvre sur les derniers échanges.
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * SectionEchanges.hauteurMax),
            child: Scrollbar(
              controller: _defilement,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _defilement,
                reverse: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
