import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_reseau.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/url_media.dart';

/// Logo rond de la société promotrice ; ses initiales tant qu'elle n'a pas envoyé de logo.
/// Rien n'est affiché si la publication ne précise ni logo ni nom.
class SocieteLogo extends StatelessWidget {
  final String? logoUrl;
  final String? nom;
  final double taille;

  /// Liseré blanc et ombre, pour une pastille posée sur une photo.
  final bool surPhoto;

  const SocieteLogo({super.key, required this.logoUrl, required this.nom, this.taille = 32, this.surPhoto = false});

  String get _initiales {
    final mots = (nom ?? '').trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).take(2);
    return mots.map((m) => m[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final url = UrlMedia.absolue(logoUrl);
    if (url == null && _initiales.isEmpty) return const SizedBox.shrink();
    final initiales = Center(
      child: Text(
        _initiales,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: taille * 0.36,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryBlueAnthracite,
        ),
      ),
    );
    return Semantics(
      label: nom == null ? 'Logo de la société' : 'Logo de $nom',
      child: Container(
        width: taille,
        height: taille,
        padding: EdgeInsets.all(url == null ? 0 : taille * 0.1),
        decoration: BoxDecoration(
          color: url == null ? AppColors.primaryOcreSoft : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: surPhoto ? AppColors.white : AppColors.borderLight, width: surPhoto ? 2 : 1),
          boxShadow: surPhoto ? AppShadows.soft : null,
        ),
        child: ClipOval(
          child: url == null
              ? initiales
              : ImageReseau(url: url, fit: BoxFit.contain, attente: initiales),
        ),
      ),
    );
  }
}

/// « Publié par » : logo et nom de la société, en tête des fiches détail.
class SocieteSignature extends StatelessWidget {
  final String? logoUrl;
  final String? nom;

  const SocieteSignature({super.key, required this.logoUrl, required this.nom});

  @override
  Widget build(BuildContext context) {
    if ((nom ?? '').trim().isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        SocieteLogo(logoUrl: logoUrl, nom: nom, taille: 38),
        const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PUBLIÉ PAR', style: AppTextStyles.overline),
              // Nom complet, sur plusieurs lignes si besoin.
              Text(nom!, style: AppTextStyles.cardTitle),
            ],
          ),
        ),
        const Icon(Icons.verified_rounded, size: 18, color: AppColors.successGreen),
      ],
    );
  }
}
