/// Formatage des dates en français, sans dépendre de l'initialisation de locale.
class DateFormatter {
  DateFormatter._();

  static const List<String> _joursCourts = [
    'LUN',
    'MAR',
    'MER',
    'JEU',
    'VEN',
    'SAM',
    'DIM',
  ];

  static String _deuxChiffres(int valeur) => valeur.toString().padLeft(2, '0');

  /// "MER"
  static String jourCourt(DateTime date) => _joursCourts[date.weekday - 1];

  /// "10:30"
  static String heure(DateTime date) =>
      '${_deuxChiffres(date.hour)}:${_deuxChiffres(date.minute)}';

  /// "10:30 - 11:30"
  static String plageHoraire(DateTime debut, DateTime fin) =>
      '${heure(debut)} - ${heure(fin)}';

  /// "Auj." ou "Jeu. 24"
  static String jourRelatif(DateTime date) {
    if (estMemeJour(date, DateTime.now())) return 'Auj.';
    final jour = jourCourt(date);
    return '${jour[0]}${jour.substring(1).toLowerCase()}. ${date.day}';
  }

  /// "36h" ou "45 min"
  static String dureeCourte(Duration duree) {
    if (duree.inHours >= 1) return '${duree.inHours}h';
    return '${duree.inMinutes} min';
  }

  static bool estMemeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime debutDuJour(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
