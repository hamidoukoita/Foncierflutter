import 'package:flutter/services.dart';

/// Nom et prénom : lettres (accents compris), espaces, tirets et apostrophes — mêmes règles que le serveur.
class NomPersonne {
  NomPersonne._();

  static const int longueurMin = 2;
  static const int longueurMax = 25;

  static final RegExp _format = RegExp(r"^\p{L}[\p{L} '’\-]*$", unicode: true);

  /// À la saisie : les chiffres et symboles ne s'écrivent pas, et la saisie s'arrête à [longueurMax].
  static final List<TextInputFormatter> formatters = [
    FilteringTextInputFormatter.allow(RegExp(r"[\p{L} '’\-]", unicode: true)),
    LengthLimitingTextInputFormatter(longueurMax),
  ];

  static String? valider(String? saisie, {required String libelle}) {
    final v = (saisie ?? '').trim();
    if (v.isEmpty) return '$libelle obligatoire';
    if (!_format.hasMatch(v)) return '$libelle : lettres uniquement';
    if (v.length < longueurMin) return '$libelle trop court';
    if (v.length > longueurMax) return '$libelle : $longueurMax caractères au maximum';
    return null;
  }
}
