import 'package:flutter/material.dart';

/// Design system officiel Foncier+ Acquéreur.
/// Palette alignée sur la maquette Figma mobile.
class AppColors {
  AppColors._();

  // Marque / actions
  static const Color primaryOcre = Color(0xFFE5801A);
  static const Color primaryOcreDark = Color(0xFFCC6F14);
  static const Color primaryOcreLight = Color(0xFFF29A43);
  static const Color primaryOcreSoft = Color(0xFFFCEBD6);
  static const Color primaryBlueAnthracite = Color(0xFF1A2B4C);
  static const Color primaryBlueSoft = Color(0xFF2A3D5C);
  static const Color brandGold = Color(0xFFE5A96A);
  static const Color brandGreen = Color(0xFF4A7A56);
  static const Color accentCoral = Color(0xFFE65335);

  // Paiement mobile (Orange Money, simulé)
  static const Color orangeMoney = Color(0xFFFF7900);
  static const Color orangeMoneySoft = Color(0xFFFFF1E5);

  // Statuts
  static const Color successGreen = Color(0xFF278443);
  static const Color successGreenSoft = Color(0xFFE4F6E9);
  static const Color errorRed = Color(0xFFD73535);
  static const Color errorRedSoft = Color(0xFFFFEBEE);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberSoft = Color(0xFFFFF2C9);
  static const Color ambreReservation24h = Color(0xFFF59E0B);

  // Statuts des lots (plan de masse) : vert disponible, or réservé, rouge vendu, gris indisponible
  static const Color lotDisponible = brandGreen;
  static const Color lotReserve = brandGold;
  static const Color lotVendu = Color(0xFFC64B4B);
  static const Color lotIndisponible = Color(0xFF73808F);

  // Surfaces
  static const Color backgroundOffWhite = Color(0xFFF8F6F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF0F172A);
  static const Color borderLight = Color(0xFFE2DDD5);
  static const Color searchIcon = Color(0xFF8FA2BA);
  static const Color heroOverlay = Color(0xA62D302D);
  static const Color constructionMint = Color(0xFFDDF8E7);
  static const Color constructionGreen = Color(0xFF178A45);

  // Illustrations de remplacement (uniquement lorsque l'API ne fournit pas de photo).
  static const Color mapCanvas = Color(0xFF287D78);
  static const Color mapDeepGreen = Color(0xFF245E54);
  static const Color mapRoad = Color(0xFF78918A);
  static const Color mapParcel = Color(0xFF48A99B);
  static const Color mapField = Color(0xFF5C9C4A);
  static const Color mapFieldLight = Color(0xFF9DC96A);

  // Espace agent : vignettes sans photo et texte secondaire sur fond anthracite
  static const Color placeholderSurface = Color(0xFFEDE9E2);
  static const Color onDarkMuted = Color(0xFFB8C1D3);

  // Nuances neutres
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  // Texte
  static const Color textPrimary = primaryBlueAnthracite;
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF8A929E);
}
