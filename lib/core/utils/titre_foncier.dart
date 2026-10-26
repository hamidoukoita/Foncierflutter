/// Numéro de Titre Foncier : toujours « TF- » suivi de la référence (ex. TF-1024/Kati).
/// Le format complet varie selon le bureau des domaines ; seul le préfixe est commun.
class TitreFoncier {
  TitreFoncier._();

  static const String prefixe = 'TF-';

  static final RegExp _prefixeSaisi =
      RegExp(r'^T\.?\s*F\.?(?=[\s\-:_n°º#.]|\d|$)[\s\-:_.]*(n\s*[°º]|#)?[\s\-:_.]*', caseSensitive: false);

  /// Référence seule, sans le préfixe éventuellement tapé : « tf 1024 / Kati » → « 1024 / Kati ».
  static String reference(String saisie) =>
      saisie.trim().replaceAll(RegExp(r'\s{2,}'), ' ').replaceFirst(_prefixeSaisi, '');

  /// Numéro enregistré : « 1024/Kati » → « TF-1024/Kati ».
  static String complet(String saisie) => '$prefixe${reference(saisie)}';

  /// Message d'erreur du champ (qui ne contient que la référence), null si elle est valide.
  static String? valider(String? saisie) {
    final ref = reference(saisie ?? '');
    if (ref.isEmpty) return 'Le numéro du Titre Foncier est obligatoire';
    if (!RegExp(r'^[\p{L}\p{N}]', unicode: true).hasMatch(ref)) {
      return 'Saisissez la référence qui suit « TF- » (ex. 1024/Kati)';
    }
    return null;
  }
}
