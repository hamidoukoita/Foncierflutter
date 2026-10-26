/// Style architectural souhaité ou proposé.
enum StyleMaison {
  moderne('MODERNE', 'Moderne'),
  traditionnel('TRADITIONNEL', 'Traditionnel / soudanais'),
  contemporain('CONTEMPORAIN', 'Contemporain'),
  libre('LIBRE', 'Au choix du promoteur');

  final String code;
  final String libelle;
  const StyleMaison(this.code, this.libelle);

  static StyleMaison? depuis(String? code) => StyleMaison.values.where((s) => s.code == code).firstOrNull;
}

enum TypeCuisine {
  interieure('INTERIEURE', 'Intérieure', 'Cuisine intérieure'),
  exterieure('EXTERIEURE', 'Extérieure', 'Cuisine extérieure'),
  lesDeux('LES_DEUX', 'Les deux', 'Cuisine intérieure et extérieure');

  final String code;
  final String libelle;
  final String description;
  const TypeCuisine(this.code, this.libelle, this.description);

  static TypeCuisine? depuis(String? code) => TypeCuisine.values.where((c) => c.code == code).firstOrNull;
}

/// Extérieurs et équipements d'une maison à construire.
enum EquipementMaison {
  terrasse('TERRASSE', 'Terrasse'),
  balcon('BALCON', 'Balcon'),
  cour('COUR', 'Cour'),
  chambreGardien('CHAMBRE_GARDIEN', 'Chambre de gardien'),
  murCloture('MUR_CLOTURE', 'Mur de clôture'),
  forage('FORAGE', 'Forage ou puits'),
  citerne('CITERNE', 'Château d’eau / citerne'),
  panneauxSolaires('PANNEAUX_SOLAIRES', 'Panneaux solaires');

  final String code;
  final String libelle;
  const EquipementMaison(this.code, this.libelle);

  static EquipementMaison? depuis(String? code) =>
      EquipementMaison.values.where((e) => e.code == code).firstOrNull;
}

/// Description d'une maison : souhaits de l'acquéreur ou maison proposée par la société.
class DescriptionMaison {
  /// 1 = plain-pied, 2 = R+1, 3 = R+2.
  final int? nombreNiveaux;
  final StyleMaison? style;
  final int? nombreChambres;

  /// Chambres avec salle de bain privative, comprises dans le nombre de chambres.
  final int? nombreSuites;
  final int? nombreSallesBain;
  final int? nombreSalons;
  final bool salleAManger;
  final bool toilettesVisiteurs;
  final bool magasin;
  final TypeCuisine? cuisine;

  /// 0 : pas de garage.
  final int? placesGarage;
  final Set<EquipementMaison> equipements;

  /// Donnée par la société dans ses propositions ; jamais demandée à l'acquéreur.
  final double? surfaceHabitable;
  final String? precisions;

  const DescriptionMaison({
    this.nombreNiveaux,
    this.style,
    this.nombreChambres,
    this.nombreSuites,
    this.nombreSallesBain,
    this.nombreSalons,
    this.salleAManger = false,
    this.toilettesVisiteurs = false,
    this.magasin = false,
    this.cuisine,
    this.placesGarage,
    this.equipements = const {},
    this.surfaceHabitable,
    this.precisions,
  });

  /// Point de départ du questionnaire : les réponses les plus courantes.
  static const DescriptionMaison parDefaut = DescriptionMaison(
    nombreNiveaux: 1,
    nombreChambres: 3,
    nombreSuites: 1,
    nombreSallesBain: 2,
    nombreSalons: 1,
    cuisine: TypeCuisine.interieure,
    placesGarage: 0,
  );

  static String? libelleNiveaux(int? niveaux) =>
      niveaux == null ? null : (niveaux <= 1 ? 'Plain-pied' : 'R+${niveaux - 1}');

  DescriptionMaison copyWith({
    int? nombreNiveaux,
    StyleMaison? Function()? style,
    int? nombreChambres,
    int? nombreSuites,
    int? nombreSallesBain,
    int? nombreSalons,
    bool? salleAManger,
    bool? toilettesVisiteurs,
    bool? magasin,
    TypeCuisine? Function()? cuisine,
    int? placesGarage,
    Set<EquipementMaison>? equipements,
  }) {
    final chambres = nombreChambres ?? this.nombreChambres;
    final suites = nombreSuites ?? this.nombreSuites;
    return DescriptionMaison(
      nombreNiveaux: nombreNiveaux ?? this.nombreNiveaux,
      style: style != null ? style() : this.style,
      nombreChambres: chambres,
      // Les chambres avec salle de bain ne peuvent pas dépasser le nombre de chambres.
      nombreSuites: (chambres != null && suites != null && suites > chambres) ? chambres : suites,
      nombreSallesBain: nombreSallesBain ?? this.nombreSallesBain,
      nombreSalons: nombreSalons ?? this.nombreSalons,
      salleAManger: salleAManger ?? this.salleAManger,
      toilettesVisiteurs: toilettesVisiteurs ?? this.toilettesVisiteurs,
      magasin: magasin ?? this.magasin,
      cuisine: cuisine != null ? cuisine() : this.cuisine,
      placesGarage: placesGarage ?? this.placesGarage,
      equipements: equipements ?? this.equipements,
      surfaceHabitable: surfaceHabitable,
      precisions: precisions,
    );
  }

  DescriptionMaison avecPrecisions(String? texte) {
    final t = texte?.trim();
    return DescriptionMaison(
      nombreNiveaux: nombreNiveaux,
      style: style,
      nombreChambres: nombreChambres,
      nombreSuites: nombreSuites,
      nombreSallesBain: nombreSallesBain,
      nombreSalons: nombreSalons,
      salleAManger: salleAManger,
      toilettesVisiteurs: toilettesVisiteurs,
      magasin: magasin,
      cuisine: cuisine,
      placesGarage: placesGarage,
      equipements: equipements,
      surfaceHabitable: surfaceHabitable,
      precisions: (t == null || t.isEmpty) ? null : t,
    );
  }

  /// Caractéristiques lisibles, dans l'ordre où un promoteur les lit.
  List<String> get caracteristiques {
    String pluriel(int n, String un, [String? plusieurs]) => '$n ${n > 1 ? (plusieurs ?? '${un}s') : un}';
    return [
      if (libelleNiveaux(nombreNiveaux) != null || style != null)
        [libelleNiveaux(nombreNiveaux), style?.libelle].whereType<String>().join(' · '),
      if (nombreChambres != null)
        pluriel(nombreChambres!, 'chambre') +
            ((nombreSuites ?? 0) > 0 ? ' dont $nombreSuites avec salle de bain' : ''),
      if ((nombreSallesBain ?? 0) > 0) pluriel(nombreSallesBain!, 'salle de bain', 'salles de bain'),
      if ((nombreSalons ?? 0) > 0) pluriel(nombreSalons!, 'salon'),
      if (salleAManger) 'Salle à manger',
      if (cuisine != null) cuisine!.description,
      if (toilettesVisiteurs) 'Toilettes visiteurs',
      if (magasin) 'Magasin / débarras',
      if ((placesGarage ?? 0) > 0) 'Garage ${pluriel(placesGarage!, 'véhicule')}',
      for (final e in EquipementMaison.values.where(equipements.contains)) e.libelle,
      if (surfaceHabitable != null) '${surfaceHabitable!.toStringAsFixed(0)} m² habitables',
    ];
  }

  Map<String, dynamic> toJson() => {
        if (nombreNiveaux != null) 'nombreNiveaux': nombreNiveaux,
        if (style != null) 'style': style!.code,
        if (nombreChambres != null) 'nombreChambres': nombreChambres,
        if (nombreSuites != null) 'nombreSuites': nombreSuites,
        if (nombreSallesBain != null) 'nombreSallesBain': nombreSallesBain,
        if (nombreSalons != null) 'nombreSalons': nombreSalons,
        'salleAManger': salleAManger,
        'toilettesVisiteurs': toilettesVisiteurs,
        'magasin': magasin,
        if (cuisine != null) 'cuisine': cuisine!.code,
        if (placesGarage != null) 'placesGarage': placesGarage,
        'equipements': [for (final e in equipements) e.code],
        if (precisions != null) 'precisions': precisions,
      };

  factory DescriptionMaison.fromJson(Map<String, dynamic> json) => DescriptionMaison(
        nombreNiveaux: (json['nombreNiveaux'] as num?)?.toInt(),
        style: StyleMaison.depuis(json['style'] as String?),
        nombreChambres: (json['nombreChambres'] as num?)?.toInt(),
        nombreSuites: (json['nombreSuites'] as num?)?.toInt(),
        nombreSallesBain: (json['nombreSallesBain'] as num?)?.toInt(),
        nombreSalons: (json['nombreSalons'] as num?)?.toInt(),
        salleAManger: json['salleAManger'] as bool? ?? false,
        toilettesVisiteurs: json['toilettesVisiteurs'] as bool? ?? false,
        magasin: json['magasin'] as bool? ?? false,
        cuisine: TypeCuisine.depuis(json['cuisine'] as String?),
        placesGarage: (json['placesGarage'] as num?)?.toInt(),
        equipements: {
          for (final c in (json['equipements'] as List?) ?? const [])
            if (EquipementMaison.depuis(c as String?) case final e?) e,
        },
        surfaceHabitable: (json['surfaceHabitable'] as num?)?.toDouble(),
        precisions: json['precisions'] as String?,
      );
}
