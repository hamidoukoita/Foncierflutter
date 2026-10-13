import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/data/models/commodite_model.dart';

/// Pictogramme d'une commodité, déduit de son icône, type ou nom.
class CommoditeIcone {
  CommoditeIcone._();

  static const List<(List<String>, IconData)> _regles = [
    (
      [
        'ecole',
        'école',
        'lycee',
        'lycée',
        'college',
        'collège',
        'educ',
        'formation'
      ],
      Icons.school_rounded
    ),
    (
      ['sante', 'santé', 'cscom', 'hopital', 'hôpital', 'clinique', 'pharmac'],
      Icons.local_hospital_rounded
    ),
    (
      ['marche', 'marché', 'commerce', 'supermarch', 'boutique', 'superette'],
      Icons.storefront_rounded
    ),
    (['mosquee', 'mosquée'], Icons.mosque_rounded),
    (['eglise', 'église', 'culte'], Icons.church_rounded),
    (
      ['police', 'gendarmerie', 'securite', 'sécurité', 'mairie', 'administr'],
      Icons.local_police_rounded
    ),
    (
      ['transport', 'sotrama', 'gare', 'bus', 'arret', 'arrêt'],
      Icons.directions_bus_rounded
    ),
    (['route', 'voie', 'goudron', 'bitum'], Icons.add_road_rounded),
    (['eau', 'somapep', 'fontaine'], Icons.water_drop_rounded),
    (['edm', 'electric', 'électric'], Icons.bolt_rounded),
  ];

  static IconData de(CommoditeModel c) =>
      depuisTexte('${c.icone ?? ''} ${c.typeLibelle ?? ''} ${c.nom}');

  /// Pictogramme à partir d'un libellé libre (type de plan de masse, nom…).
  static IconData depuisTexte(String libelle) {
    final texte = libelle.toLowerCase();
    for (final (motsCles, icone) in _regles) {
      if (motsCles.any(texte.contains)) return icone;
    }
    return Icons.place_rounded;
  }
}
