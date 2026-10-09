import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/lot_programme.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';

/// Détail d'une cité / programme — maquette Figma « Détails cité ».
class ProgrammeDetailScreen extends ConsumerWidget {
  final int programmeId;

  const ProgrammeDetailScreen({super.key, required this.programmeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progAsync = ref.watch(programmeDetailProvider(programmeId));
    final lotsAsync = ref.watch(lotsByProgrammeProvider(programmeId));

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
                        child: _HeroHeader(
                          onBack: () => context.pop(),
                          seed: programme.id,
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
                              const _SectionTitle('Commodités aux alentours'),
                              const SizedBox(height: 10),
                              const _CommoditesGrid(),
                              const SizedBox(height: 18),
                              const _SectionTitle('Plan de masse du lotissement'),
                              const SizedBox(height: 10),
                              _PlanPreview(
                                seed: programme.id,
                                lotsCount: lots.length,
                                onOpenPlan: () =>
                                    _showLotsSheet(context, lots, programme),
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
                              _showLotsSheet(context, lots, programme),
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

  void _showLotsSheet(
    BuildContext context,
    List<LotProgramme> lots,
    ProgrammeFoncier programme,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Lots — ${programme.nom}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                      ),
                      Text(
                        '${lots.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: lots.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun lot disponible.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          itemCount: lots.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final lot = lots[i];
                            return Material(
                              color: AppColors.backgroundOffWhite,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  context.push('/prospect/lots/${lot.id}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColors.borderLight),
                                        ),
                                        child: Text(
                                          lot.numeroLot ?? '${i + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            color: AppColors.primaryBlueAnthracite,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lot.displayRef,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: AppColors
                                                    .primaryBlueAnthracite,
                                              ),
                                            ),
                                            Text(
                                              [
                                                if (lot.superficie != null)
                                                  '${lot.superficie!.toStringAsFixed(0)} m²',
                                                if (lot.statut != null) lot.statut!,
                                              ].join(' • '),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (lot.prix != null)
                                        Text(
                                          _formatPrice(lot.prix!),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            color: AppColors.primaryOcre,
                                          ),
                                        ),
                                      const Icon(Icons.chevron_right_rounded,
                                          color: AppColors.grey400),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String _formatPrice(double v) {
    final s = v.toStringAsFixed(0);
    final chars = s.split('').reversed.toList();
    final out = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) out.add(' ');
      out.add(chars[i]);
    }
    return '${out.reversed.join()} FCFA';
  }
}

class _HeroHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int seed;

  const _HeroHeader({required this.onBack, required this.seed});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 220 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mapDeepGreen,
                  AppColors.mapCanvas,
                  AppColors.mapField,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CustomPaint(painter: _ParcelOverlayPainter(seed: seed)),
          Positioned(
            top: top + 8,
            left: 12,
            child: Material(
              color: Colors.white.withOpacity(0.92),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParcelOverlayPainter extends CustomPainter {
  final int seed;
  _ParcelOverlayPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF2ECC71).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fill = Paint()
      ..color = const Color(0xFF2ECC71).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final cols = 5;
    final rows = 4;
    final pad = 16.0;
    final cellW = (size.width - pad * 2) / cols;
    final cellH = (size.height - pad * 2) / rows;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final dx = ((seed + r * 3 + c) % 5) * 2.0;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            pad + c * cellW + 3,
            pad + r * cellH + 3 + dx,
            cellW - 8,
            cellH - 10,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, fill);
        canvas.drawRRect(rect, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParcelOverlayPainter oldDelegate) =>
      oldDelegate.seed != seed;
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

class _CommoditesGrid extends StatelessWidget {
  const _CommoditesGrid();

  static const _items = [
    (Icons.local_hospital_outlined, 'Centre de santé', 'À proximité'),
    (Icons.school_outlined, 'Groupe scolaire', 'À proximité'),
    (Icons.storefront_outlined, 'Grand Marché', 'À proximité'),
    (Icons.mosque_outlined, 'Lieu de culte', 'À proximité'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: _items
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
                    child: Icon(e.$1, size: 18, color: AppColors.primaryOcre),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                        Text(
                          e.$3,
                          style: const TextStyle(
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
  final int seed;
  final int lotsCount;
  final VoidCallback onOpenPlan;

  const _PlanPreview({
    required this.seed,
    required this.lotsCount,
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mapFieldLight,
                    AppColors.mapCanvas,
                    AppColors.mapDeepGreen,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            CustomPaint(painter: _ParcelOverlayPainter(seed: seed + 7)),
            Positioned(
              right: 12,
              bottom: 12,
              child: Material(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onOpenPlan,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      lotsCount > 0
                          ? 'Voir le plan ($lotsCount lots) ›'
                          : 'Voir le plan ›',
                      style: const TextStyle(
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
    );
  }
}
