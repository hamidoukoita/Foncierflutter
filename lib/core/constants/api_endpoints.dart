/// Chemins relatifs à [AppConstants.apiBaseUrl] (déjà préfixé /api).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String registerAcquereur = '/auth/register';
  static const String registerSociete = '/auth/register-societe';

  // Programmes & lots
  static const String programmes = '/programmes-fonciers';
  static String programmeById(int id) => '/programmes-fonciers/$id';
  static String lotsByProgramme(int programmeId) =>
      '/lots-programmes/programme/$programmeId';
  static const String lotsProgrammes = '/lots-programmes';
  static const String parcelles = '/parcelles-individuelles';

  // Réservations & RDV
  static const String reservations = '/reservations';
  static const String rendezVous = '/rendez-vous';

  // Biens (vue polymorphique), créneaux de visite et médias
  static String bienById(int id) => '/biens-fonciers/$id';
  static const String creneaux = '/creneaux';
  static String planMasseByProgramme(int programmeId) =>
      '/plans-masse/programme/$programmeId';
  static String planElements(int planMasseId) =>
      '/plans-masse-elements/plan-masse/$planMasseId';
  static String mediasByProgramme(int programmeId) =>
      '/medias/programme/$programmeId';
  static String mediasByBien(int bienId) => '/medias/bien/$bienId';

  // Construction
  static const String projetsConstruction = '/projets-construction';
  static String projetsByAcquereur(int id) =>
      '/projets-construction/acquereur/$id';
  static String projetsBySociete(int id) => '/projets-construction/societe/$id';
  static const String modelesMaison = '/modeles-maison';

  // Société / agents
  static const String agents = '/agents-promoteurs';
  static const String societes = '/societes-promotrices';
}
