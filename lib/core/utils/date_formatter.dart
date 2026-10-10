/// Formatage des dates en français, sans dépendre de l'initialisation des locales `intl`.
class DateFormatter {
  DateFormatter._();

  static const List<String> _mois = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  static const List<String> _jours = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
  ];

  static String _2(int n) => n.toString().padLeft(2, '0');

  /// 09/10/2026
  static String date(DateTime d) => '${_2(d.day)}/${_2(d.month)}/${d.year}';

  /// vendredi 9 octobre 2026
  static String dateLongue(DateTime d) =>
      '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]} ${d.year}';

  /// 09h30
  static String heure(DateTime d) => '${_2(d.hour)}h${_2(d.minute)}';

  /// Format attendu par Spring pour un LocalDateTime (sans fuseau).
  static String isoLocal(DateTime d) {
    final local = d.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${_2(local.month)}-${_2(local.day)}'
        'T${_2(local.hour)}:${_2(local.minute)}:${_2(local.second)}';
  }
}
