import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/models/media_model.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/hero_media.dart';

/// Gabarit commun des pages de détail (cité, lot, parcelle) : même hero, mêmes cartes, même barre d'actions.
class DetailPage extends StatelessWidget {
  final String title;
  final List<MediaModel> medias;
  final bool mediasLoading;
  final VoidCallback onBack;
  final List<Widget> children;
  final Widget? bottomBar;
  final Future<void> Function()? onRefresh;

  const DetailPage({
    super.key,
    required this.title,
    required this.medias,
    required this.onBack,
    required this.children,
    this.mediasLoading = false,
    this.bottomBar,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        DetailSliverAppBar(title: title, medias: medias, loading: mediasLoading, onBack: onBack),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
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

/// Barre d'actions fixe en bas.
class DetailActionBar extends StatelessWidget {
  final List<Widget> actions;
  const DetailActionBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlueAnthracite.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }
}

class DetailButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;
  final Color? color;

  const DetailButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.loading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? (primary ? AppColors.primaryOcre : AppColors.primaryBlueAnthracite);
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        else if (icon != null)
          Icon(icon, size: 19),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(label,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ],
    );
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          disabledBackgroundColor: bg.withOpacity(0.6),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: child,
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

  const DetailHeader({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    this.subtitle,
    this.subtitleIcon = Icons.location_on_outlined,
    this.onSubtitleTap,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlueAnthracite,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              StatusPill(label: statusLabel, color: statusColor),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: onSubtitleTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Icon(subtitleIcon, size: 17, color: AppColors.primaryOcre),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (onSubtitleTap != null)
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.grey500),
                ],
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in tags) _Tag(t)],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryBlueAnthracite),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
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

/// Bandeau de 2 à 3 chiffres clés.
class StatStrip extends StatelessWidget {
  final List<StatItem> items;
  const StatStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: _cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderLight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i].icon, size: 20, color: AppColors.primaryOcre),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          items[i].value,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: items[i].highlight ? AppColors.primaryOcre : AppColors.primaryBlueAnthracite,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(items[i].label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.borderLight),
      boxShadow: [
        BoxShadow(color: AppColors.primaryBlueAnthracite.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 5)),
      ],
    );

/// Carte de section avec titre à barre orange.
class DetailSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DetailSection({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
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
                  height: 16,
                  decoration: BoxDecoration(color: AppColors.primaryOcre, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite)),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Ligne « libellé — valeur » séparée par un filet.
class InfoRows extends StatelessWidget {
  final List<(String, String)> rows;
  const InfoRows({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.grey200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rows[i].$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    rows[i].$2,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primaryBlueAnthracite),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite)),
          const SizedBox(height: 2),
          Text(subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
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
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}
