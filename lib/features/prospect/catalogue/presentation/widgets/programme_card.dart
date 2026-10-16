import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/badge_360.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/societe_logo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/url_media.dart';
import 'programme_cover.dart';

/// Carte annonce d'une cité : couverture, statut, chiffres clés, VRD, prix.
class ProgrammeCard extends StatelessWidget {
  final ProgrammeFoncier programme;
  final VoidCallback? onTap;

  const ProgrammeCard({super.key, required this.programme, this.onTap});

  static const double _hauteurCouverture = 150;

  @override
  Widget build(BuildContext context) {
    final statut = _StatutCite.de(programme.statut);
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: AppRadius.card, boxShadow: AppShadows.card),
      child: Material(
        color: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _hauteurCouverture,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Couverture(programme: programme),
                    Positioned(
                      left: AppSpacing.md - AppSpacing.xs,
                      top: AppSpacing.md - AppSpacing.xs,
                      child: SoftBadge(
                        label: statut.libelle,
                        background: statut.fond,
                        foreground: statut.couleur,
                      ),
                    ),
                    const Positioned(
                      right: AppSpacing.md - AppSpacing.xs,
                      top: AppSpacing.md - AppSpacing.xs,
                      child: SoftBadge(
                        label: 'Agréé',
                        icon: Icons.verified_rounded,
                        background: AppColors.white,
                        foreground: AppColors.successGreen,
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md - AppSpacing.xs,
                      bottom: AppSpacing.md - AppSpacing.xs,
                      child: Badge360(nombre: programme.nombrePanoramas),
                    ),
                    Positioned(
                      right: AppSpacing.md - AppSpacing.xs,
                      bottom: AppSpacing.md - AppSpacing.xs,
                      child: SocieteLogo(logoUrl: programme.societeLogoUrl, nom: programme.societeNom, taille: 34, surPhoto: true),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programme.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _Localisation(programme: programme),
                    const SizedBox(height: AppSpacing.md - AppSpacing.xs),
                    _Pied(programme: programme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Localisation extends StatelessWidget {
  final ProgrammeFoncier programme;
  const _Localisation({required this.programme});

  @override
  Widget build(BuildContext context) {
    final texte = [
      if ((programme.lieu ?? '').isNotEmpty) programme.lieu!,
      if ((programme.societeNom ?? '').isNotEmpty) programme.societeNom!,
    ].join(' • ');
    return Row(
      children: [
        const Icon(Icons.location_on_rounded,
            size: 15, color: AppColors.primaryOcre),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(texte,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}

/// Chiffres clés, pictogrammes de viabilisation et accès à la fiche.
class _Pied extends StatelessWidget {
  final ProgrammeFoncier programme;
  const _Pied({required this.programme});

  String? get _surface {
    final s = programme.superficieTotale;
    if (s == null) return null;
    return s >= 10000
        ? '${(s / 10000).toStringAsFixed(s >= 100000 ? 0 : 1)} ha'
        : '${s.toStringAsFixed(0)} m²';
  }

  @override
  Widget build(BuildContext context) {
    final infos = [
      if (programme.totalLots != null) '${programme.totalLots} lots',
      if (_surface != null) _surface!,
    ].join(' · ');
    return Row(
      children: [
        if (infos.isNotEmpty)
          Text(infos,
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(width: AppSpacing.sm),
        if (programme.eauSomapep == true)
          const _Vrd(Icons.water_drop_rounded, 'Eau SOMAPEP'),
        if (programme.electriciteEdm == true)
          const _Vrd(Icons.bolt_rounded, 'Électricité EDM'),
        if (programme.voirieBitumee == true)
          const _Vrd(Icons.add_road_rounded, 'Voirie bitumée'),
        const Spacer(),
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
              color: AppColors.primaryOcreSoft, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_forward_rounded,
              size: 18, color: AppColors.primaryOcreDark),
        ),
      ],
    );
  }
}

class _Vrd extends StatelessWidget {
  final IconData icone;
  final String libelle;
  const _Vrd(this.icone, this.libelle);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: libelle,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
            color: AppColors.successGreenSoft, shape: BoxShape.circle),
        child: Icon(icone, size: 14, color: AppColors.successGreen),
      ),
    );
  }
}

class _StatutCite {
  final String libelle;
  final Color fond;
  final Color couleur;
  const _StatutCite(this.libelle, this.fond, this.couleur);

  static _StatutCite de(String? statut) {
    final s = (statut ?? '').toUpperCase();
    if (s.contains('VENIR') ||
        s.contains('BROUILLON') ||
        s.contains('INDISPONIBLE')) {
      return const _StatutCite(
          'À venir', AppColors.warningAmberSoft, AppColors.ambreReservation24h);
    }
    if (s.contains('TERMINE') || s.contains('COMPLET') || s.contains('VENDU')) {
      return const _StatutCite('Complet', AppColors.grey200, AppColors.grey700);
    }
    return const _StatutCite('Commercialisation', AppColors.successGreenSoft,
        AppColors.successGreen);
  }
}

/// Photo de couverture de la cité ; illustration de plan en attendant ou à défaut.
class _Couverture extends StatelessWidget {
  final ProgrammeFoncier programme;
  const _Couverture({required this.programme});

  @override
  Widget build(BuildContext context) {
    final url = UrlMedia.absolue(programme.imageUrl);
    final illustration = ProgrammeCover(seed: programme.id);
    if (url == null) return illustration;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => illustration,
      errorWidget: (_, __, ___) => illustration,
    );
  }
}
