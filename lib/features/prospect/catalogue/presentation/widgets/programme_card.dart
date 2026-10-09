import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';

/// Carte programme — style Figma « Cités & Plan ».
class ProgrammeCard extends StatelessWidget {
  final ProgrammeFoncier programme;
  final VoidCallback? onTap;

  const ProgrammeCard({
    super.key,
    required this.programme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(programme.statut);
    final lots = programme.totalLots;
    final surfaceHa = programme.superficieTotale != null
        ? (programme.superficieTotale! / 10000).toStringAsFixed(
            programme.superficieTotale! >= 10000 ? 0 : 1,
          )
        : null;
    final metaParts = <String>[
      if (lots != null) '$lots lots',
      if (surfaceHa != null) '$surfaceHa ha',
      if (programme.eauSomapep == true ||
          programme.electriciteEdm == true ||
          programme.voirieBitumee == true)
        _viabilisationLabel(),
    ];

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlueAnthracite.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(seed: programme.id, statut: programme.statut),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programme.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlueAnthracite,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if ((programme.lieu ?? '').isNotEmpty) programme.lieu!,
                        if ((programme.societeNom ?? '').isNotEmpty)
                          programme.societeNom!,
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: status.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: status.fg,
                        ),
                      ),
                    ),
                    if (metaParts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.terrain_outlined,
                              size: 14, color: AppColors.grey500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              metaParts.join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        text: 'À partir de ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: _priceLabel(programme),
                            style: const TextStyle(
                              color: AppColors.primaryOcre,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _viabilisationLabel() {
    final n = [
      programme.eauSomapep == true,
      programme.electriciteEdm == true,
      programme.voirieBitumee == true,
    ].where((e) => e).length;
    return '$n viabilisé${n > 1 ? 's' : ''}';
  }

  String _priceLabel(ProgrammeFoncier p) {
    // Prix mini non exposé par l'API programmes → tiret élégant
    return 'sur devis';
  }

  static _StatusInfo _statusInfo(String? statut) {
    final s = (statut ?? '').toUpperCase();
    if (s.contains('VENIR') || s.contains('BROUILLON') || s.contains('PREVI')) {
      return const _StatusInfo(
        label: 'À venir',
        bg: Color(0xFFFFF3C4),
        fg: Color(0xFFB45309),
      );
    }
    if (s.contains('TERMINE') || s.contains('CLOTUR') || s.contains('VENDU')) {
      return const _StatusInfo(
        label: 'Terminé',
        bg: AppColors.grey200,
        fg: AppColors.grey700,
      );
    }
    return const _StatusInfo(
      label: 'En cours',
      bg: Color(0xFFE4F6E9),
      fg: Color(0xFF278443),
    );
  }
}

class _StatusInfo {
  final String label;
  final Color bg;
  final Color fg;
  const _StatusInfo({required this.label, required this.bg, required this.fg});
}

class _Thumb extends StatelessWidget {
  final int seed;
  final String? statut;

  const _Thumb({required this.seed, this.statut});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.mapCanvas,
      AppColors.mapDeepGreen,
      AppColors.mapParcel,
      AppColors.mapField,
    ];
    final c1 = colors[seed % colors.length];
    final c2 = colors[(seed + 1) % colors.length];

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c1, c2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Motif « plan » simplifié
            CustomPaint(painter: _PlanGridPainter(seed: seed)),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.map_outlined,
                    size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanGridPainter extends CustomPainter {
  final int seed;
  _PlanGridPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const step = 14.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final fill = Paint()..color = Colors.white.withOpacity(0.12);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.25, size.width * 0.35,
          size.height * 0.35),
      const Radius.circular(3),
    );
    canvas.drawRRect(r, fill);
  }

  @override
  bool shouldRepaint(covariant _PlanGridPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
