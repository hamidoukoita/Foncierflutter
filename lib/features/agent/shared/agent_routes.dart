/// Chemins de navigation de l'espace agent.
class AgentRoutes {
  AgentRoutes._();

  static const String dashboard = '/agent/dashboard';
  static const String visites = '/agent/visites';
  static const String reservations = '/agent/reservations';
  static const String visiteDetailPattern = '/agent/visite/:id';

  static String visiteDetail(int id) => '/agent/visite/$id';
}
