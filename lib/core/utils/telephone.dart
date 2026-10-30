import 'package:flutter/services.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/pays.dart';

/// Numéros de téléphone de tous les pays. Le serveur les reçoit et les stocke au format
/// international E.164 (+22376123456) ; un numéro saisi sans indicatif y est lu comme malien.
class Telephone {
  Telephone._();

  /// Au plus 15 chiffres indicatif compris (norme E.164).
  static const int chiffresMax = 15;

  static String chiffres(String saisie) => saisie.replaceAll(RegExp(r'\D'), '');

  static PhoneNumber? _analyser(Pays pays, String saisie) {
    final c = chiffres(saisie);
    if (c.isEmpty) return null;
    try {
      return PhoneNumber.parse(c, destinationCountry: pays.isoCode);
    } catch (_) {
      return null;
    }
  }

  /// « 6 12 34 56 78 » pour la France → « +33612345678 ».
  static String e164(Pays pays, String saisie) =>
      _analyser(pays, saisie)?.international ?? '+${pays.indicatif}${chiffres(saisie)}';

  /// Message d'erreur du champ, null si le numéro est valide pour [pays].
  static String? valider(Pays pays, String? saisie) {
    if (chiffres(saisie ?? '').isEmpty) return 'Numéro obligatoire';
    final numero = _analyser(pays, saisie!);
    if (numero == null || !numero.isValid()) return 'Numéro invalide pour ${pays.nom} (ex. ${pays.exemple})';
    return null;
  }

  /// Numéro enregistré (E.164, ou ancien format malien à 8 chiffres) → numéro analysé.
  static PhoneNumber? analyserEnregistre(String? numero) {
    final brut = (numero ?? '').trim();
    final c = chiffres(brut);
    if (c.isEmpty) return null;
    final international = brut.startsWith('+') ? '+$c' : (c.length == 8 ? '+223$c' : '+$c');
    try {
      return PhoneNumber.parse(international);
    } catch (_) {
      return null;
    }
  }

  /// Affichage : « 76 12 34 56 » pour un numéro malien, « +33 6 12 34 56 78 » sinon.
  /// [avecIndicatif] ajoute aussi « +223 » aux numéros maliens.
  static String afficher(String? numero, {bool avecIndicatif = false}) {
    final n = analyserEnregistre(numero);
    if (n == null) return numero ?? '';
    final national = n.formatNsn(format: NsnFormat.international);
    return n.isoCode == IsoCode.ML && !avecIndicatif ? national : '+${n.countryCode} $national';
  }

  /// Pays d'un numéro enregistré (Mali par défaut).
  static Pays paysDe(String? numero) => Pays.parIso(analyserEnregistre(numero)?.isoCode.name) ?? Pays.mali;

  /// Partie nationale d'un numéro enregistré, mise en forme pour pré-remplir un champ.
  static String nationalDe(String? numero) =>
      analyserEnregistre(numero)?.formatNsn(format: NsnFormat.international) ?? '';
}

/// Saisie guidée de la partie nationale : chiffres seuls, groupés selon les règles du pays.
class TelephoneFormatter extends TextInputFormatter {
  final Pays pays;

  TelephoneFormatter(this.pays);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue ancien, TextEditingValue nouveau) {
    final max = Telephone.chiffresMax - pays.indicatif.length;
    var c = Telephone.chiffres(nouveau.text);
    if (c.length > max) c = c.substring(0, max);
    final texte = PhoneNumberFormatter.formatNsn(c, pays.isoCode, NsnFormat.international);
    return TextEditingValue(text: texte, selection: TextSelection.collapsed(offset: texte.length));
  }
}
