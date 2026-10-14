/// Chemins de l'onglet « Clés en main ».
class ClesEnMainRoutes {
  ClesEnMainRoutes._();

  static const String liste = '/prospect/cles-en-main';
  static const String detailPattern = '/prospect/maisons/:id';
  static String detail(int id) => '/prospect/maisons/$id';
}
