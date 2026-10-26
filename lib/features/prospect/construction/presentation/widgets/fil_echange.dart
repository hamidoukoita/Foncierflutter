import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import '../../domain/echange_projet.dart';
import 'carte_proposition.dart';

/// Discussion avec la société : vos messages à droite, les siens à gauche, ses propositions en cartes.
class FilEchange extends StatelessWidget {
  final List<ElementFil> elements;
  final String? societeNom;

  /// Les boutons de réponse ne sont proposés que tant que le dossier est en cours.
  final bool peutRepondre;
  final void Function(PropositionProjet) onAccepter;
  final void Function(PropositionProjet) onDecliner;

  const FilEchange({
    super.key,
    required this.elements,
    required this.peutRepondre,
    required this.onAccepter,
    required this.onDecliner,
    this.societeNom,
  });

  @override
  Widget build(BuildContext context) {
    if (elements.isEmpty) {
      return Text(
        'Le promoteur étudie votre dossier. Il pourra vous poser des questions ou vous faire des propositions ici.',
        style: AppTextStyles.bodySmall,
      );
    }
    return Column(
      children: [
        for (final e in elements)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xxs),
            child: switch (e) {
              MessageFil(:final message) => _Bulle(message: message),
              PropositionFil(:final proposition) => CarteProposition(
                  proposition: proposition,
                  societeNom: societeNom,
                  onAccepter: peutRepondre && proposition.enAttente ? () => onAccepter(proposition) : null,
                  onDecliner: peutRepondre && proposition.enAttente ? () => onDecliner(proposition) : null,
                ),
            },
          ),
      ],
    );
  }
}

class _Bulle extends StatelessWidget {
  final MessageProjet message;
  const _Bulle({required this.message});

  @override
  Widget build(BuildContext context) {
    final moi = message.cote == CoteEchange.acquereur;
    final date = message.dateEnvoi;
    return Align(
      alignment: moi ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md - AppSpacing.xxs, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: moi ? AppColors.primaryBlueAnthracite : AppColors.white,
            border: moi ? null : Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(moi ? 16 : 4),
              bottomRight: Radius.circular(moi ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.texte,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: moi ? AppColors.white : AppColors.primaryBlueAnthracite, height: 1.4)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                [
                  if (!moi && message.auteurNom != null) message.auteurNom!,
                  if (date != null) '${DateFormatter.date(date)} · ${DateFormatter.heure(date)}',
                ].join(' · '),
                style: AppTextStyles.bodySmall
                    .copyWith(fontSize: 11, color: moi ? AppColors.onDarkMuted : AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zone d'écriture fixée en bas de l'écran du projet.
class ZoneMessage extends StatefulWidget {
  final bool envoi;
  final Future<bool> Function(String texte) onEnvoyer;

  const ZoneMessage({super.key, required this.envoi, required this.onEnvoyer});

  @override
  State<ZoneMessage> createState() => _ZoneMessageState();
}

class _ZoneMessageState extends State<ZoneMessage> {
  final _texte = TextEditingController();

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final t = _texte.text.trim();
    if (t.isEmpty || widget.envoi) return;
    if (await widget.onEnvoyer(t) && mounted) _texte.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _texte,
                minLines: 1,
                maxLines: 4,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Écrire au promoteur…', counterText: ''),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton.filled(
              tooltip: 'Envoyer',
              onPressed: widget.envoi ? null : _envoyer,
              style: IconButton.styleFrom(backgroundColor: AppColors.primaryOcre),
              icon: widget.envoi
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Icon(Icons.send_rounded, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
