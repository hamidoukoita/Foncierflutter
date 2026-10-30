import 'package:flutter/widgets.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/pays.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone.dart';

/// État d'un champ téléphone : pays choisi et partie nationale saisie.
/// À créer dans le State de l'écran et à libérer dans son dispose().
class SaisieTelephone {
  final TextEditingController texte;
  final ValueNotifier<Pays> pays;

  SaisieTelephone({String? numero})
      : texte = TextEditingController(text: Telephone.nationalDe(numero)),
        pays = ValueNotifier(numero == null ? Pays.mali : Telephone.paysDe(numero));

  /// Numéro complet au format international, tel qu'attendu par le serveur.
  String get e164 => Telephone.e164(pays.value, texte.text);

  String? valider(String? _) => Telephone.valider(pays.value, texte.text);

  void dispose() {
    texte.dispose();
    pays.dispose();
  }
}
