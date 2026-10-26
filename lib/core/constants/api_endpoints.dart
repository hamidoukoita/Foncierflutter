/// Chemins relatifs à [AppConstants.apiBaseUrl] (déjà préfixé /api).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String registerAcquereur = '/auth/register';
  static const String registerSociete = '/auth/register-societe';
  static String identiteAcquereur(int id) => '/acquereurs/$id/identite';
  static const String monTelephone = '/comptes/moi/telephone';
  static const String monMotDePasse = '/comptes/moi/mot-de-passe';
  static const String motDePasseOublie = '/auth/mot-de-passe-oublie';
  static const String motDePasseOublieConfirmer = '/auth/mot-de-passe-oublie/confirmer';

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
  static String reservationsByAcquereur(int acquereurId) =>
      '/reservations/acquereur/$acquereurId';
  static String conditionsReservation(int bienId) =>
      '/reservations/conditions/$bienId';
  static String annulerReservation(int id) => '/reservations/$id/annuler';
  static String demarrerReservation(int id) => '/reservations/$id/demarrer';
  static String vendreReservation(int id) => '/reservations/$id/vendre';
  // Bien vendu à un autre acquéreur : report sur un autre bien ou remboursement.
  static String biensRemplacement(int id) => '/reservations/$id/biens-remplacement';
  static String rembourserReservation(int id) => '/reservations/$id/remboursement';
  static String remplacerReservation(int id, int bienId) =>
      '/reservations/$id/remplacement/$bienId';

  // Notifications
  static String notificationsByUtilisateur(int utilisateurId) =>
      '/notifications/utilisateur/$utilisateurId';
  static String lireNotification(int id) => '/notifications/$id/lire';
  static String toutLireNotifications(int utilisateurId) =>
      '/notifications/utilisateur/$utilisateurId/tout-lire';
  static String lireNotificationsCible(String cibleType, int cibleId) =>
      '/notifications/cible/$cibleType/$cibleId/lire';

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
  static String mediasByModele(int modeleId) => '/medias/modele/$modeleId';
  static String visiteVirtuelleByBien(int bienId) => '/medias/bien/$bienId/visite';
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
  static String filProjet(int id) => '/projets-construction/$id/fil';
  static String messagesProjet(int id) => '/projets-construction/$id/messages';
  static String accepterProposition(int id) => '/projets-construction/propositions/$id/accepter';
  static String refuserProposition(int id) => '/projets-construction/propositions/$id/refuser';
  static const String modelesMaison = '/modeles-maison';

  // Maisons clés en main
  static const String maisonsCleEnMain = '/maisons-cle-en-main';
  static String maisonById(int id) => '/maisons-cle-en-main/$id';
  static String maisonsDeSociete(int id) => '/maisons-cle-en-main/societe/$id';

  // Société / agents
  static const String agents = '/agents-promoteurs';
  static const String societes = '/societes-promotrices';
}
