import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import '../../domain/description_maison.dart';
import '../controllers/champs_projet.dart';

/// Questionnaire guidé de la maison souhaitée (modèle personnalisé) : des choix et des compteurs
/// plutôt que du texte libre, pour que le promoteur reçoive tout ce qu'il lui faut.
class QuestionnaireMaison extends StatelessWidget {
  final ChampsProjet champs;
  final GlobalKey<FormState> formKey;

  const QuestionnaireMaison({super.key, required this.champs, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ValueListenableBuilder<DescriptionMaison>(
        valueListenable: champs.souhaits,
        builder: (context, s, _) {
          void maj(DescriptionMaison d) => champs.souhaits.value = d;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section(
                icone: Icons.domain_rounded,
                titre: 'La structure',
                children: [
                  const _Question('Combien de niveaux ?'),
                  _Choix<int>(
                    options: const {1: 'Plain-pied', 2: 'R+1 (un étage)', 3: 'R+2 (deux étages)'},
                    valeur: s.nombreNiveaux,
                    onChanged: (v) => maj(s.copyWith(nombreNiveaux: v)),
                  ),
                  const _Question('Quel style vous plaît ?'),
                  _ChoixStyle(
                    valeur: s.style,
                    onChanged: (v) => maj(s.copyWith(style: () => v)),
                  ),
                ],
              ),
              _Section(
                icone: Icons.bed_outlined,
                titre: 'Les pièces',
                children: [
                  _Compteur(
                    libelle: 'Chambres',
                    valeur: s.nombreChambres ?? 0,
                    min: 1,
                    max: 15,
                    onChanged: (v) => maj(s.copyWith(nombreChambres: v)),
                  ),
                  _Compteur(
                    libelle: 'dont avec salle de bain',
                    aide: 'Chambre avec sa propre douche et ses toilettes',
                    valeur: s.nombreSuites ?? 0,
                    max: s.nombreChambres ?? 0,
                    onChanged: (v) => maj(s.copyWith(nombreSuites: v)),
                  ),
                  _Compteur(
                    libelle: 'Salles de bain communes',
                    valeur: s.nombreSallesBain ?? 0,
                    max: 10,
                    onChanged: (v) => maj(s.copyWith(nombreSallesBain: v)),
                  ),
                  _Compteur(
                    libelle: 'Salons',
                    valeur: s.nombreSalons ?? 0,
                    max: 5,
                    onChanged: (v) => maj(s.copyWith(nombreSalons: v)),
                  ),
                  const _Question('La cuisine'),
                  _Choix<TypeCuisine>(
                    options: {for (final c in TypeCuisine.values) c: c.libelle},
                    valeur: s.cuisine,
                    onChanged: (v) => maj(s.copyWith(cuisine: () => v)),
                  ),
                  const _Question('Vous souhaitez aussi'),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _Option(
                        libelle: 'Salle à manger',
                        actif: s.salleAManger,
                        onChanged: (v) => maj(s.copyWith(salleAManger: v)),
                      ),
                      _Option(
                        libelle: 'Toilettes visiteurs',
                        actif: s.toilettesVisiteurs,
                        onChanged: (v) => maj(s.copyWith(toilettesVisiteurs: v)),
                      ),
                      _Option(
                        libelle: 'Magasin / débarras',
                        actif: s.magasin,
                        onChanged: (v) => maj(s.copyWith(magasin: v)),
                      ),
                    ],
                  ),
                ],
              ),
              _Section(
                icone: Icons.yard_outlined,
                titre: 'L’extérieur et les équipements',
                children: [
                  _Compteur(
                    libelle: 'Garage',
                    aide: 'Nombre de véhicules (0 : pas de garage)',
                    valeur: s.placesGarage ?? 0,
                    max: 5,
                    onChanged: (v) => maj(s.copyWith(placesGarage: v)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final e in EquipementMaison.values)
                        _Option(
                          libelle: e.libelle,
                          actif: s.equipements.contains(e),
                          onChanged: (oui) => maj(s.copyWith(
                            equipements: oui ? {...s.equipements, e} : ({...s.equipements}..remove(e)),
                          )),
                        ),
                    ],
                  ),
                ],
              ),
              _Section(
                icone: Icons.lightbulb_outline_rounded,
                titre: 'Y a-t-il autre chose d’important pour vous ?',
                children: [
                  Text(
                    'Facultatif. Par exemple : une chambre au rez-de-chaussée pour un parent âgé, un grand salon '
                    'pour recevoir, une cuisine fermée, une maison facile à agrandir plus tard…',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: champs.precisionsMaison,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 3000,
                    decoration: const InputDecoration(hintText: 'Vos précisions pour le promoteur'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icone;
  final String titre;
  final List<Widget> children;

  const _Section({required this.icone, required this.titre, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: AppColors.primaryOcre),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(titre, style: AppTextStyles.cardTitle)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  final String texte;
  const _Question(this.texte);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(texte, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

/// Choix unique parmi quelques options ; un second appui sur l'option choisie la retire.
class _Choix<T> extends StatelessWidget {
  final Map<T, String> options;
  final T? valeur;
  final ValueChanged<T?> onChanged;

  const _Choix({required this.options, required this.valeur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final MapEntry(key: cle, value: libelle) in options.entries)
          ChoiceChip(
            label: Text(libelle),
            selected: valeur == cle,
            selectedColor: AppColors.primaryOcreSoft,
            onSelected: (oui) => onChanged(oui ? cle : null),
          ),
      ],
    );
  }
}

/// Icône et explication de chaque style, pour qui ne connaît pas les termes d'architecture.
extension _PresentationStyle on StyleMaison {
  IconData get icone => switch (this) {
        StyleMaison.moderne => Icons.domain_rounded,
        StyleMaison.traditionnel => Icons.fort_rounded,
        StyleMaison.contemporain => Icons.villa_outlined,
        StyleMaison.libre => Icons.auto_awesome_outlined,
      };

  String get explication => switch (this) {
        StyleMaison.moderne => 'Lignes droites, toit plat, grandes fenêtres',
        StyleMaison.traditionnel => 'Façades en banco ou crépi, à la manière de Djenné',
        StyleMaison.contemporain => 'Volumes originaux, matériaux mélangés',
        StyleMaison.libre => 'Le promoteur vous conseille',
      };
}

/// Styles en tuiles illustrées, deux par ligne ; un second appui retire le choix.
class _ChoixStyle extends StatelessWidget {
  final StyleMaison? valeur;
  final ValueChanged<StyleMaison?> onChanged;

  const _ChoixStyle({required this.valeur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        const ecart = AppSpacing.sm;
        final largeur = (contraintes.maxWidth - ecart) / 2;
        return Wrap(
          spacing: ecart,
          runSpacing: ecart,
          children: [
            for (final style in StyleMaison.values)
              SizedBox(
                width: largeur,
                child: _TuileStyle(
                  style: style,
                  choisi: valeur == style,
                  onTap: () => onChanged(valeur == style ? null : style),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TuileStyle extends StatelessWidget {
  final StyleMaison style;
  final bool choisi;
  final VoidCallback onTap;

  const _TuileStyle({required this.style, required this.choisi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: choisi,
      button: true,
      child: Material(
        color: choisi ? AppColors.primaryOcreSoft : AppColors.backgroundOffWhite,
        borderRadius: AppRadius.radiusMd,
        child: InkWell(
          borderRadius: AppRadius.radiusMd,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: choisi ? AppColors.primaryOcre : AppColors.borderLight,
                width: choisi ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(style.icone,
                        size: 28, color: choisi ? AppColors.primaryOcreDark : AppColors.primaryBlueAnthracite),
                    const Spacer(),
                    if (choisi) const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primaryOcre),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                Text(style.libelle,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.xxs),
                Text(style.explication, style: AppTextStyles.bodySmall.copyWith(height: 1.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String libelle;
  final bool actif;
  final ValueChanged<bool> onChanged;

  const _Option({required this.libelle, required this.actif, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(libelle),
      selected: actif,
      selectedColor: AppColors.primaryOcreSoft,
      checkmarkColor: AppColors.primaryOcreDark,
      onSelected: onChanged,
    );
  }
}

/// Compteur « − n + » borné.
class _Compteur extends StatelessWidget {
  final String libelle;
  final String? aide;
  final int valeur;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Compteur({
    required this.libelle,
    required this.valeur,
    required this.max,
    required this.onChanged,
    this.aide,
    this.min = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(libelle, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (aide != null) Text(aide!, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          _BoutonCompteur(
            icone: Icons.remove_rounded,
            semantique: 'Retirer',
            onTap: valeur > min ? () => onChanged(valeur - 1) : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$valeur',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle.copyWith(color: AppColors.primaryBlueAnthracite),
            ),
          ),
          _BoutonCompteur(
            icone: Icons.add_rounded,
            semantique: 'Ajouter',
            onTap: valeur < max ? () => onChanged(valeur + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _BoutonCompteur extends StatelessWidget {
  final IconData icone;
  final String semantique;
  final VoidCallback? onTap;

  const _BoutonCompteur({required this.icone, required this.semantique, this.onTap});

  @override
  Widget build(BuildContext context) {
    final actif = onTap != null;
    return Semantics(
      button: true,
      label: semantique,
      child: Material(
        color: actif ? AppColors.primaryOcreSoft : AppColors.backgroundOffWhite,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icone, size: 20, color: actif ? AppColors.primaryOcreDark : AppColors.borderLight),
          ),
        ),
      ),
    );
  }
}
