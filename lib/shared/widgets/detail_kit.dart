import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_sizes.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/visite_virtuelle_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/hero_media.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/societe_logo.dart';

/// Gabarit commun des pages de détail (cité, lot, parcelle) : même hero, mêmes cartes, même barre d'actions.
class DetailPage extends StatelessWidget {
  final String title;
  final List<MediaModel> medias;
  final bool mediasLoading;
  final VoidCallback onBack;
  final List<Widget> children;
  final Widget? bottomBar;
  final Future<void> Function()? onRefresh;

  /// Visite pièce par pièce (maisons clés en main) : pièce de départ et points de passage.
  final VisiteVirtuelleModel visite;

  const DetailPage({
    super.key,
    required this.title,
    required this.medias,
    required this.onBack,
    required this.children,
    this.mediasLoading = false,
    this.bottomBar,
    this.onRefresh,
    this.visite = VisiteVirtuelleModel.vide,
  });

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        DetailSliverAppBar(
          title: title,
          medias: medias,
          loading: mediasLoading,
          onBack: onBack,
          visite: visite,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md + AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.md + AppSpacing.xs,
            AppSpacing.xl,
          ),
          sliver: SliverList(delegate: SliverChildListDelegate(children)),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: Column(
        children: [
          Expanded(
            child: onRefresh == null
                ? scroll
                : RefreshIndicator(color: AppColors.primaryOcre, onRefresh: onRefresh!, child: scroll),
          ),
          if (bottomBar != null) bottomBar!,
        ],
      ),
    );
  }
}

/// Barre d'actions fixe en bas, arrondie et légèrement surélevée.
class DetailActionBar extends StatelessWidget {
  final List<Widget> actions;
  const DetailActionBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md + AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md + AppSpacing.xs,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        boxShadow: AppShadows.floating,
      ),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }
}

/// Bouton des fiches : plein (dégradé ocre ou couleur fournie), contouré ou danger.
class DetailButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;
  final Color? color;

  /// Bouton contouré (action secondaire) ; avec [danger] : contour rouge (annulation).
  final bool outline;
  final bool danger;

  /// Hauteur compacte (cartes de liste) ou standard (barres d'actions).
  final bool compact;

  const DetailButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.loading = false,
    this.color,
    this.outline = false,
    this.danger = false,
    this.compact = false,
  });

  bool get _contoure => outline || danger;

  @override
  Widget build(BuildContext context) {
    final height = compact ? AppSizes.buttonMedium : AppSizes.buttonLarge - 2;
    final actif = onPressed != null && !loading;

    final Color texte = _contoure
        ? (danger ? AppColors.errorRed : (color ?? AppColors.primaryBlueAnthracite))
        : AppColors.white;
    final Color? fondUni = _contoure
        ? AppColors.white
        : (color ?? (primary ? null : AppColors.primaryBlueAnthracite));
    final bool degrade = !_contoure && fondUni == null;

    return Opacity(
      opacity: onPressed == null && !loading ? 0.55 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: fondUni,
          gradient: degrade ? AppGradients.cta : null,
          borderRadius: AppRadius.button,
          border: _contoure
              ? Border.all(
                  color: danger ? AppColors.errorRed.withValues(alpha: 0.5) : AppColors.borderLight,
                  width: 1.5,
                )
              : null,
          boxShadow: degrade && actif ? AppShadows.cta : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.button,
            onTap: actif ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: texte),
                    )
                  else if (icon != null)
                    Icon(icon, size: 19, color: texte),
                  if (loading || icon != null) const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.buttonLarge.copyWith(color: texte, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// En-tête : titre, pastille de statut, sous-titre et étiquettes.
class DetailHeader extends StatelessWidget {
  final String title;
  final String statusLabel;
  final Color statusColor;
  final String? subtitle;
  final IconData subtitleIcon;
  final VoidCallback? onSubtitleTap;
  final List<String> tags;

  /// Société qui publie le bien : logo et nom affichés sous le titre (« Publié par »).
  final String? societeNom;
  final String? societeLogoUrl;

  const DetailHeader({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    this.subtitle,
    this.subtitleIcon = Icons.location_on_outlined,
    this.onSubtitleTap,
    this.tags = const [],
    this.societeNom,
    this.societeLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(label: statusLabel, color: statusColor),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Text(title, style: AppTextStyles.pageTitle.copyWith(fontSize: 26)),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: onSubtitleTap,
              borderRadius: AppRadius.radiusSm,
              child: Row(
                children: [
                  Icon(subtitleIcon, size: 17, color: AppColors.primaryOcre),
                  const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (onSubtitleTap != null)
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.grey500),
                ],
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [for (final t in tags) _Tag(t)],
            ),
          ],
          if ((societeNom ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: SocieteSignature(logoUrl: societeLogoUrl, nom: societeNom),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + AppSpacing.xxs, vertical: AppSpacing.xs + 1),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusRound,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_outlined, size: 13, color: AppColors.successGreen),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlueAnthracite,
          )),
        ],
      ),
    );
  }
}

/// Pastille de statut avec point coloré.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + AppSpacing.xs, vertical: AppSpacing.xs + 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.radiusRound,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class StatItem {
  final IconData icon;
  final String value;
  final String label;
  final bool highlight;
  const StatItem(this.icon, this.value, this.label, {this.highlight = false});
}

/// Bandeau de 2 à 3 chiffres clés, chacun dans sa pastille.
class StatStrip extends StatelessWidget {
  final List<StatItem> items;
  const StatStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
          Expanded(child: _StatTile(item: items[i])),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final StatItem item;
  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final mise = item.highlight;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md - AppSpacing.xxs, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: mise ? null : AppColors.white,
        gradient: mise ? AppGradients.navy : null,
        borderRadius: AppRadius.card,
        border: mise ? null : Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 20, color: mise ? AppColors.primaryOcreLight : AppColors.primaryOcre),
          const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.value,
              maxLines: 1,
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w800,
                color: mise ? AppColors.white : AppColors.primaryBlueAnthracite,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: mise ? AppColors.onDarkMuted : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.white,
      borderRadius: AppRadius.card,
      border: Border.all(color: AppColors.borderLight),
      boxShadow: AppShadows.card,
    );

/// Carte de section avec titre à barre ocre.
class DetailSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DetailSection({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.cta,
                    borderRadius: AppRadius.radiusRound,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                Expanded(child: Text(title, style: AppTextStyles.cardTitle)),
              ],
            ),
            const SizedBox(height: AppSpacing.md - AppSpacing.xxs),
            child,
          ],
        ),
      ),
    );
  }
}

/// Lignes « libellé — valeur » séparées par un filet.
class InfoRows extends StatelessWidget {
  final List<(String, String)> rows;
  const InfoRows({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + AppSpacing.xs),
            decoration: BoxDecoration(
              border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.grey200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rows[i].$1, style: AppTextStyles.bodyMedium),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Text(
                    rows[i].$2,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Tuile d'équipement (eau, électricité, voirie…) : vert si présent, gris sinon.
class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool ok;
  const FeatureTile({super.key, required this.icon, required this.title, required this.subtitle, required this.ok});

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.successGreen : AppColors.grey500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + AppSpacing.xxs, vertical: AppSpacing.md - AppSpacing.xs),
      decoration: BoxDecoration(
        color: ok ? AppColors.successGreenSoft : AppColors.grey100,
        borderRadius: AppRadius.radiusLg,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xxs),
          Text(subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

/// Rangée de tuiles de même largeur.
class FeatureRow extends StatelessWidget {
  final List<FeatureTile> tiles;
  const FeatureRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

/// Décoration commune de toutes les cartes (listes et sections).
BoxDecoration appCardDecoration({Color? borderColor}) => _cardDecoration().copyWith(
      border: Border.all(color: borderColor ?? AppColors.borderLight, width: borderColor == null ? 1 : 1.5),
    );

/// Option d'une barre de filtres.
class AppFilterOption<T> {
  final T value;
  final String label;
  final Color? color;
  const AppFilterOption(this.value, this.label, {this.color});
}

/// Barre de filtres unique pour toute l'application : pastilles défilantes, sélection pleine.
class AppFilterBar<T> extends StatelessWidget {
  final List<AppFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry padding;

  const AppFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md + AppSpacing.xs),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final o = options[i];
          final on = o.value == selected;
          final color = o.color ?? AppColors.primaryOcre;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: on ? color : AppColors.white,
              borderRadius: AppRadius.radiusRound,
              border: Border.all(color: on ? color : AppColors.borderLight),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: AppRadius.radiusRound,
                onTap: () => onChanged(o.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Center(
                    child: Text(
                      o.label,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: on ? AppColors.white : AppColors.primaryBlueAnthracite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Champ de recherche unique (s'appuie sur le thème des champs).
class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const AppSearchField({super.key, required this.controller, required this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: AppRadius.input, boxShadow: AppShadows.card),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlueAnthracite),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md - AppSpacing.xxs),
        ),
      ),
    );
  }
}
