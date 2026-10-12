/// Libellés d'affichage d'un bien foncier à partir des champs plats renvoyés
/// par le backend (`bienDesignation`, `bienReference`, `programmeNom`).
class BienLibelle {
  BienLibelle._();

  /// "Lot 05" pour un lot de cité, "Parcelle PARC-012" pour une parcelle individuelle.
  static String court({
    String? designation,
    String? reference,
    String? programmeNom,
  }) {
    final valeur = designation ?? reference ?? '';
    if (valeur.isEmpty) return '';
    return programmeNom != null ? 'Lot $valeur' : 'Parcelle $valeur';
  }

  /// Joint les éléments non vides par " • ".
  static String joindre(Iterable<String?> elements) => elements
      .whereType<String>()
      .where((e) => e.trim().isNotEmpty)
      .join(' • ');
}
