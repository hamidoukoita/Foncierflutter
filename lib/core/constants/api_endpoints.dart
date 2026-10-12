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
  static String rendezVousById(int id) => '/rendez-vous/$id';
  static String rendezVousByAgent(int agentId) => '/rendez-vous/agent/$agentId';
  static String accepterRendezVous(int id) => '/rendez-vous/$id/accepter';
  static String reservationsByAgent(int agentId) =>
      '/reservations/agent/$agentId';

  // Biens fonciers
  static String bienFoncierById(int id) => '/biens-fonciers/$id';

  // Notifications
  static String notificationsByUtilisateur(int utilisateurId) =>
      '/notifications/utilisateur/$utilisateurId';

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
