import 'package:flutter/services.dart';

/// Saisie d'un montant en FCFA : chiffres seuls, groupés par milliers (« 200 000 000 »).
class MontantSaisie {
  MontantSaisie._();

  /// Au-delà, la saisie s'arrête (100 milliards).
  static const int chiffresMax = 12;

  static String chiffres(String texte) => texte.replaceAll(RegExp(r'\D'), '');

  /// « 200000000 » → « 200 000 000 ».
  static String grouper(String chiffres) {
    final tampon = StringBuffer();
    for (var i = 0; i < chiffres.length; i++) {
      if (i > 0 && (chiffres.length - i) % 3 == 0) tampon.write(' ');
      tampon.write(chiffres[i]);
    }
    return tampon.toString();
  }

  /// « 200 000 000 » → 200000000 ; vide → null.
  static double? valeur(String texte) {
    final c = chiffres(texte);
    return c.isEmpty ? null : double.parse(c);
  }
}

/// Regroupe les chiffres par milliers pendant la frappe, en gardant le curseur
/// à sa place parmi les chiffres.
class MontantFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue ancien, TextEditingValue nouveau) {
    var chiffres = MontantSaisie.chiffres(nouveau.text).replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (chiffres.length > MontantSaisie.chiffresMax) return ancien;
    final texte = MontantSaisie.grouper(chiffres);

    // Nombre de chiffres avant le curseur, reporté dans le texte groupé.
    final curseur = nouveau.selection.baseOffset.clamp(0, nouveau.text.length);
    final chiffresAvant = MontantSaisie.chiffres(nouveau.text.substring(0, curseur)).length;
    var position = 0;
    for (var vus = 0; position < texte.length && vus < chiffresAvant; position++) {
      if (texte[position] != ' ') vus++;
    }
    return TextEditingValue(text: texte, selection: TextSelection.collapsed(offset: position));
  }
}
