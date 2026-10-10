import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/domain/plan_masse.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/plan/presentation/widgets/plan_masse_view.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/hero_media.dart';

/// Détail d'une cité / programme — maquette Figma « Détails cité ».
class ProgrammeDetailScreen extends ConsumerWidget {
  final int programmeId;

  const ProgrammeDetailScreen({super.key, required this.programmeId});

  /// Équipements réellement dessinés sur le plan (aucune donnée inventée).
  static List<PlanElement> _commodites(PlanMasse? plan) {
    if (plan == null) return const [];
    final vus = <String>{};
    final out = <PlanElement>[];
    for (final e in plan.elements) {
      if (!e.visible || e.isRoute || e.type == 'ESPACE_VERT') continue;
      if (vus.add('${e.type}|${e.nom ?? ''}')) out.add(e);
    }
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progAsync = ref.watch(programmeDetailProvider(programmeId));
    final lotsAsync = ref.watch(lotsByProgrammeProvider(programmeId));
    final mediasAsync = ref.watch(programmeMediasProvider(programmeId));
    final planAsync = ref.watch(planMasseProvider(programmeId));

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: progAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOcre),
        ),
        error: (e, _) => SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$e', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => context.pop(), child: const Text('Retour')),
                ],
              ),
            ),
          ),
        ),
        data: (programme) {
          final lots = lotsAsync.valueOrNull ?? <LotProgramme>[];
          final progress = ((programme.avancement ?? 0).clamp(0, 100)) / 100.0;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryOcre,
                  onRefresh: () async {
                    ref.invalidate(programmeDetailProvider(programmeId));
                    ref.invalidate(lotsByProgrammeProvider(programmeId));
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: HeroMedia(
                          medias: mediasAsync.valueOrNull ?? const [],
                          loading: mediasAsync.isLoading,
                          height: 230,
                          onBack: () => context.pop(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _IdentityCard(
                                programme: programme,
                                lotsCount: lots.isNotEmpty
                                    ? lots.length
                                    : (programme.totalLots ?? 0),
                              ),
                              const SizedBox(height: 14),
                              _SectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Avancement des travaux',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${programme.avancement ?? 0}%',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryBlueAnthracite,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor: AppColors.grey200,
                                        color: AppColors.successGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              const _SectionTitle('Viabilisation du site (VRD)'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _VrdChip(
                                      icon: Icons.water_drop_outlined,
                                      title: 'Eau potable',
                                      subtitle: programme.eauSomapep == true
                                          ? 'Raccordé'
                                          : 'Non raccordé',
                                      ok: programme.eauSomapep == true,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _VrdChip(
                                      icon: Icons.bolt_outlined,
                                      title: 'Réseau EDM',
                                      subtitle: programme.electriciteEdm == true
                                          ? 'Poteau posé'
                                          : 'Non raccordé',
                                      ok: programme.electriciteEdm == true,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _VrdChip(
                                      icon: Icons.alt_route_rounded,
                                      title: 'Voie bitumée',
                                      subtitle: programme.voirieBitumee == true
                                          ? 'Bitume'
                                          : 'Non bitumée',
                                      ok: programme.voirieBitumee == true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              if (_commodites(planAsync.valueOrNull).isNotEmpty) ...[
                                const _SectionTitle('Commodités du lotissement'),
                                const SizedBox(height: 10),
                                _CommoditesGrid(items: _commodites(planAsync.valueOrNull)),
                                const SizedBox(height: 18),
                              ],
                              const _SectionTitle('Plan de masse du lotissement'),
                              const SizedBox(height: 10),
                              _PlanPreview(
                                lots: lotsAvecGeometrie(lots),
                                elements: planAsync.valueOrNull?.elements
                                        .where((e) => e.visible)
                                        .toList() ??
                                    const [],
                                lotsCount: lots.length,
                                onOpenPlan: () =>
                                    context.push('/prospect/programmes/$programmeId/plan'),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Localisation : disponible lorsque les coordonnées GPS sont renseignées.',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlueAnthracite,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Voir la localisation',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push('/prospect/programmes/$programmeId/lots'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOcre,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Voir lots',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final ProgrammeFoncier programme;
  final int lotsCount;

  const _IdentityCard({required this.programme, required this.lotsCount});

  @override
  Widget build(BuildContext context) {
    final status = _status(programme.statut);
    final surfaceHa = programme.superficieTotale != null
        ? (programme.superficieTotale! / 10000).toStringAsFixed(
            programme.superficieTotale! >= 10000 ? 0 : 1,
          )
        : null;

    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlueAnthracite.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    programme.nom,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlueAnthracite,
                      height: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.$2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.$1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: status.$3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.primaryOcre),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [
                      if ((programme.lieu ?? '').isNotEmpty) programme.lieu!,
                      if ((programme.societeNom ?? '').isNotEmpty)
                        programme.societeNom!,
                    ].join(' • '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if ((programme.numeroTitreMere ?? '').isNotEmpty)
                  Text(
                    'TF Mère : ${programme.numeroTitreMere}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Meta(icon: Icons.grid_view_rounded, text: '$lotsCount lots'),
                const SizedBox(width: 14),
                if (surfaceHa != null)
                  _Meta(icon: Icons.terrain_outlined, text: '$surfaceHa ha'),
                const Spacer(),
                const Text(
                  'Dès ',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Text(
                  'sur devis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryOcre,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// label, bg, fg
  static (String, Color, Color) _status(String? statut) {
    final s = (statut ?? '').toUpperCase();
    if (s.contains('VENIR') || s.contains('BROUILLON')) {
      return ('À venir', const Color(0xFFFFF3C4), const Color(0xFFB45309));
    }
    return ('En cours', const Color(0xFFE4F6E9), const Color(0xFF278443));
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.grey500),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlueAnthracite,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlueAnthracite,
      ),
    );
  }
}

class _VrdChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool ok;

  const _VrdChip({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: ok ? AppColors.successGreen : AppColors.grey400),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlueAnthracite,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            ok ? '✓ $subtitle' : subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: ok ? AppColors.successGreen : AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconePourElement(String type) {
  switch (type) {
    case 'MOSQUEE':
      return Icons.mosque_outlined;
    case 'EGLISE':
      return Icons.church_outlined;
    case 'ECOLE':
      return Icons.school_outlined;
    case 'MARCHE':
      return Icons.storefront_outlined;
    case 'COMMERCE':
      return Icons.shopping_bag_outlined;
    case 'EQUIPEMENT_PUBLIC':
      return Icons.account_balance_outlined;
    default:
      return Icons.place_outlined;
  }
}

class _CommoditesGrid extends StatelessWidget {
  final List<PlanElement> items;
  const _CommoditesGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: items
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundOffWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_iconePourElement(e.type), size: 18, color: AppColors.primaryOcre),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.affichage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                        const Text(
                          'Dans le lotissement',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryOcre,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlanPreview extends StatelessWidget {
  final List<PlanLotShape> lots;
  final List<PlanElement> elements;
  final int lotsCount;
  final VoidCallback onOpenPlan;

  const _PlanPreview({
    required this.lots,
    required this.elements,
    required this.lotsCount,
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: lots.isEmpty ? null : onOpenPlan,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          width: double.infinity,
          color: const Color(0xFFEFEBE0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (lots.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Le plan de masse n\'a pas encore été publié par la société.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlanMiniature(lots: lots, elements: elements, showLabels: false),
                ),
              if (lots.isNotEmpty)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: onOpenPlan,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          'Voir le plan ›',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
