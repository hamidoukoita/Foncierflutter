import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/image_reseau.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/soft_badge.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/badge_360.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/societe_logo.dart';
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
                    const SizedBox(height: AppSpacing.sm),
                    _DisponibiliteLots(programme: programme),
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

/// Où en sont les lots de la cité : combien restent libres, ou tout est vendu / réservé.
/// Couleurs du plan : vert disponible, orange réservé, rouge vendu.
class _DisponibiliteLots extends StatelessWidget {
  final ProgrammeFoncier programme;
  const _DisponibiliteLots({required this.programme});

  @override
  Widget build(BuildContext context) {
    final total = programme.totalLots ?? 0;
    final libres = programme.lotsDisponibles;
    if (total == 0 || libres == null) return const SizedBox.shrink();

    final (couleur, icone, texte) = switch (libres) {
      > 0 => (
          AppColors.lotDisponible,
          Icons.check_circle_rounded,
          libres == 1 ? '1 lot disponible sur $total' : '$libres lots disponibles sur $total',
        ),
      _ when (programme.lotsVendus ?? 0) >= total =>
        (AppColors.lotVendu, Icons.do_not_disturb_on_rounded, 'Tous les lots sont vendus'),
      _ => (AppColors.lotReserve, Icons.schedule_rounded, 'Aucun lot libre : tous réservés ou vendus'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: AppRadius.radiusRound,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 15, color: couleur),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              texte,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: couleur, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
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
    return ImageReseau(url: url, attente: illustration);
  }
}
