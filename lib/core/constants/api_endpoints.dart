/// Chemins relatifs à [AppConstants.apiBaseUrl] (déjà préfixé /api).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String registerAcquereur = '/auth/register';
  static const String registerSociete = '/auth/register-societe';
  static String identiteAcquereur(int id) => '/acquereurs/$id/identite';

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
  static String rendezVousById(int id) => '/rendez-vous/$id';
  static String rendezVousByAgent(int agentId) => '/rendez-vous/agent/$agentId';
  static String accepterRendezVous(int id) => '/rendez-vous/$id/accepter';
  static String reservationsByAgent(int agentId) =>
      '/reservations/agent/$agentId';

  // Notifications
  static String notificationsByUtilisateur(int utilisateurId) =>
      '/notifications/utilisateur/$utilisateurId';

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
  static String proximitesByProgramme(int programmeId) =>
      '/proximites-commodites/programme/$programmeId';
  static String proximitesByBien(int bienId) =>
      '/proximites-commodites/bien/$bienId';

  // Construction
  static const String projetsConstruction = '/projets-construction';
  static String projetsByAcquereur(int id) =>
      '/projets-construction/acquereur/$id';
  static String projetsBySociete(int id) => '/projets-construction/societe/$id';
  static String projetById(int id) => '/projets-construction/$id';
  static String fichiersProjet(int id) => '/projets-construction/$id/fichiers';
  static const String modelesMaison = '/modeles-maison';

  // Maisons clés en main
  static const String maisonsCleEnMain = '/maisons-cle-en-main';
  static String maisonById(int id) => '/maisons-cle-en-main/$id';
  static String maisonsDeSociete(int id) => '/maisons-cle-en-main/societe/$id';

  // Société / agents
  static const String agents = '/agents-promoteurs';
  static const String societes = '/societes-promotrices';
}
