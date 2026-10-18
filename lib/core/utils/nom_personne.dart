import 'package:flutter/services.dart';

/// Nom et prénom : lettres (accents compris), espaces, tirets et apostrophes — mêmes règles que le serveur.
class NomPersonne {
  NomPersonne._();

  static final RegExp _format = RegExp(r"^\p{L}[\p{L} '’\-]*$", unicode: true);

  /// À la saisie : les chiffres et symboles ne s'écrivent pas.
  static final TextInputFormatter formatter =
      FilteringTextInputFormatter.allow(RegExp(r"[\p{L} '’\-]", unicode: true));

  static String? valider(String? saisie, {required String libelle}) {
    final v = (saisie ?? '').trim();
    if (v.isEmpty) return '$libelle obligatoire';
    if (!_format.hasMatch(v)) return '$libelle : lettres uniquement';
    return null;
  }
}
