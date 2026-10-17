import 'package:flutter/services.dart';

/// Numéro de téléphone malien : 8 chiffres après l'indicatif +223, affichés « xx xx xx xx ».
/// Mobiles (5, 6, 7, 8, 9) et fixes (2).
class TelephoneMali {
  TelephoneMali._();

  static const int longueur = 8;
  static final RegExp _format = RegExp(r'^[25-9]\d{7}$');

  /// Chiffres seuls, tels qu'enregistrés et utilisés pour se connecter.
  static String chiffres(String saisie) => saisie.replaceAll(RegExp(r'\D'), '');

  static bool estValide(String saisie) => _format.hasMatch(chiffres(saisie));

  /// Message d'erreur du champ, null si le numéro est valide.
  static String? valider(String? saisie) {
    final n = chiffres(saisie ?? '');
    if (n.isEmpty) return 'Numéro obligatoire';
    if (n.length != longueur) return 'Le numéro compte 8 chiffres (xx xx xx xx)';
    if (!_format.hasMatch(n)) return 'Numéro malien invalide';
    return null;
  }

  /// « 76123456 » → « 76 12 34 56 ».
  static String formater(String saisie) {
    final n = chiffres(saisie);
    final buffer = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      if (i > 0 && i.isEven) buffer.write(' ');
      buffer.write(n[i]);
    }
    return buffer.toString();
  }
}

/// Saisie guidée : chiffres uniquement, 8 au plus, groupés par deux pendant la frappe.
class TelephoneMaliFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue ancien, TextEditingValue nouveau) {
    final chiffres = TelephoneMali.chiffres(nouveau.text);
    final limites = chiffres.length > TelephoneMali.longueur ? chiffres.substring(0, TelephoneMali.longueur) : chiffres;
    final texte = TelephoneMali.formater(limites);
    return TextEditingValue(text: texte, selection: TextSelection.collapsed(offset: texte.length));
  }
}
