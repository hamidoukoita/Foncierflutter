/// Chemins de la carte de localisation (écran plein, hors barre de navigation).
class LocalisationRoutes {
  LocalisationRoutes._();

  static const String programmePattern =
      '/prospect/programmes/:id/localisation';
  static const String bienPattern = '/prospect/biens/:id/localisation';

  static String programme(int id) => '/prospect/programmes/$id/localisation';
  static String bien(int id) => '/prospect/biens/$id/localisation';
}
