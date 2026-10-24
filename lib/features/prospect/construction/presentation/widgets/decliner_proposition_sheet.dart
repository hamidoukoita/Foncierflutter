import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';
import '../../domain/echange_projet.dart';

/// Réponse « décliner » : l'acquéreur explique ce qui ne lui convient pas, pour une meilleure proposition.
class DeclinerPropositionSheet extends StatefulWidget {
  final PropositionProjet proposition;
  const DeclinerPropositionSheet({super.key, required this.proposition});

  /// Null si l'acquéreur renonce ; sinon son commentaire (éventuellement vide).
  static Future<({String? commentaire})?> show(BuildContext context, PropositionProjet proposition) {
    return showModalBottomSheet<({String? commentaire})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => DeclinerPropositionSheet(proposition: proposition),
    );
  }

  @override
  State<DeclinerPropositionSheet> createState() => _DeclinerPropositionSheetState();
}

class _DeclinerPropositionSheetState extends State<DeclinerPropositionSheet> {
  final _commentaire = TextEditingController();

  static const _suggestions = ['Trop cher pour mon budget', 'Il manque des pièces', 'Le délai est trop long'];

  @override
  void dispose() {
    _commentaire.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Décliner la proposition n°${widget.proposition.numero}', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.xs),
            Text('Dites au promoteur ce qui ne vous convient pas : il pourra vous proposer autre chose.',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final s in _suggestions)
                  ActionChip(label: Text(s), onPressed: () => setState(() => _commentaire.text = s)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _commentaire,
              minLines: 2,
              maxLines: 5,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Votre explication (facultatif)'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(text: 'Annuler', isSecondary: true, onPressed: () => Navigator.of(context).pop()),
                ),
                const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                Expanded(
                  child: PrimaryButton(
                    text: 'Décliner',
                    onPressed: () => Navigator.of(context).pop((commentaire: _commentaire.text.trim())),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
