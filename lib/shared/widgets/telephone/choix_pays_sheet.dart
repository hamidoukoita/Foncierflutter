import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/pays.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';

/// Choix du pays de l'indicatif : recherche par nom ou indicatif, pays de la diaspora
/// malienne en tête, puis tous les pays par ordre alphabétique.
class ChoixPaysSheet extends StatefulWidget {
  final Pays actuel;

  const ChoixPaysSheet({super.key, required this.actuel});

  static Future<Pays?> afficher(BuildContext context, {required Pays actuel}) {
    return showModalBottomSheet<Pays>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => ChoixPaysSheet(actuel: actuel),
    );
  }

  @override
  State<ChoixPaysSheet> createState() => _ChoixPaysSheetState();
}

class _ChoixPaysSheetState extends State<ChoixPaysSheet> {
  final _recherche = TextEditingController();
  String _filtre = '';

  static final List<Pays> _frequents = [
    for (final iso in Pays.diaspora)
      if (Pays.parIso(iso) case final pays?) pays,
  ];

  /// Comparaison sans accents ni majuscules (« cote » trouve « Côte d’Ivoire »).
  static String _simplifier(String texte) {
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ÿ': 'y',
      '’': "'"
    };
    return texte.toLowerCase().split('').map((c) => accents[c] ?? c).join();
  }

  bool _correspond(Pays p) {
    final f = _simplifier(_filtre.trim());
    if (f.isEmpty) return true;
    final indicatif = f.replaceAll('+', '');
    return _simplifier(p.nom).contains(f) || (indicatif.isNotEmpty && p.indicatif.startsWith(indicatif));
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frequents = _filtre.isEmpty ? _frequents : const <Pays>[];
    final tous = Pays.tous.where(_correspond).toList();
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: AppRadius.radiusRound),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('Indicatif du pays', style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
              child: AppSearchField(
                controller: _recherche,
                hint: 'Rechercher un pays ou un indicatif',
                onChanged: (v) => setState(() => _filtre = v),
              ),
            ),
            Expanded(
              child: tous.isEmpty
                  ? Center(child: Text('Aucun pays trouvé', style: AppTextStyles.bodyMedium))
                  : ListView(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      children: [
                        if (frequents.isNotEmpty) ...[
                          const _Titre('Pays fréquents'),
                          for (final p in frequents) _LignePays(pays: p, choisi: p.iso == widget.actuel.iso),
                          const _Titre('Tous les pays'),
                        ],
                        for (final p in tous) _LignePays(pays: p, choisi: p.iso == widget.actuel.iso),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titre extends StatelessWidget {
  final String texte;
  const _Titre(this.texte);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
      child: Text(texte.toUpperCase(), style: AppTextStyles.overline),
    );
  }
}

class _LignePays extends StatelessWidget {
  final Pays pays;
  final bool choisi;

  const _LignePays({required this.pays, required this.choisi});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      selected: choisi,
      selectedTileColor: AppColors.primaryOcreSoft,
      leading: Text(pays.drapeau, style: const TextStyle(fontSize: 24)),
      title: Text(pays.nom, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlueAnthracite)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('+${pays.indicatif}', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
          if (choisi) ...[
            AppSpacing.gapSm,
            const Icon(Icons.check_circle_rounded, color: AppColors.primaryOcre, size: 20),
          ],
        ],
      ),
      onTap: () => Navigator.of(context).pop(pays),
    );
  }
}
