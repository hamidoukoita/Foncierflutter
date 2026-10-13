/// Dimensions standard des contrôles (boutons, icônes, navigation).
class AppSizes {
  AppSizes._();

  static const double buttonLarge = 54;
  static const double buttonMedium = 46;
  static const double buttonSmall = 40;

  static const double iconButton = 44;
  static const double avatar = 48;

  static const double navBarHeight = 66;
  static const double navBarMargin = 14;

  /// Espace à réserver en bas des listes pour ne pas passer sous la barre flottante.
  static const double navBarClearance = navBarHeight + navBarMargin * 2;
}
