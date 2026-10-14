/// Chemins du parcours « Construire sur mon terrain ».
class ConstructionRoutes {
  ConstructionRoutes._();

  static const String liste = '/prospect/construction';
  static const String nouveau = '/prospect/construction/nouveau';
  static const String detailPattern = '/prospect/construction/:id';
  static String detail(int id) => '/prospect/construction/$id';
}
