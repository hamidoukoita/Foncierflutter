import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_gradients.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_shadows.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';

/// Deux plages possibles pour une visite : matinée ou après-midi.
enum RdvPeriode {
  matin('Matinée', '09h00 à 12h30', 9),
  apresMidi('Après-midi', '14h00 à 17h00', 14);

  final String libelle;
  final String horaires;
  final int heureDebut;
  const RdvPeriode(this.libelle, this.horaires, this.heureDebut);
}

/// Page « Prise de rendez-vous » : lieu (siège / chantier), jour, matinée ou après-midi, récapitulatif.
/// (Nom conservé : appelée via `RdvBookingSheet.show(...)` depuis les fiches lot et parcelle.)
class RdvBookingSheet extends ConsumerStatefulWidget {
  final int bienId;
  final int? societeId;
  final String bienLabel;
  final String? societeNom;
  final String? chantierLabel;

  const RdvBookingSheet({
    super.key,
    required this.bienId,
    required this.societeId,
    required this.bienLabel,
    this.societeNom,
    this.chantierLabel,
  });

  static Future<void> show(
    BuildContext context, {
    required int bienId,
    required int? societeId,
    required String bienLabel,
    String? societeNom,
    String? chantierLabel,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RdvBookingSheet(
          bienId: bienId,
          societeId: societeId,
          bienLabel: bienLabel,
          societeNom: societeNom,
          chantierLabel: chantierLabel,
        ),
      ),
    );
  }

  @override
  ConsumerState<RdvBookingSheet> createState() => _RdvBookingSheetState();
}

class _RdvBookingSheetState extends ConsumerState<RdvBookingSheet> {
  static const _joursCourts = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
  static const _moisNoms = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  late final List<DateTime> _jours = _prochainsJours();
  String _type = 'SIEGE';
  DateTime? _jour;
  RdvPeriode? _periode;
  bool _saving = false;
  String? _error;

  /// 12 prochains jours ouvrés (lundi – vendredi), à partir d'aujourd'hui.
  static List<DateTime> _prochainsJours() {
    final out = <DateTime>[];
    var d = DateTime.now();
    d = DateTime(d.year, d.month, d.day);
    while (out.length < 12) {
      if (d.weekday <= DateTime.friday) out.add(d);
      d = d.add(const Duration(days: 1));
    }
    return out;
  }

  DateTime _debut(DateTime jour, RdvPeriode p) =>
      DateTime(jour.year, jour.month, jour.day, p.heureDebut);

  bool _periodePassee(DateTime jour, RdvPeriode p) =>
      _debut(jour, p).isBefore(DateTime.now());

  String get _lieuTexte {
    if (_type == 'SIEGE') {
      final n = (widget.societeNom ?? '').trim();
      return n.isEmpty ? 'Siège de la société' : 'Siège $n';
    }
    final c = (widget.chantierLabel ?? '').trim();
    return c.isEmpty ? 'Sur le chantier' : 'Chantier $c';
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider).user;
    final jour = _jour;
    final periode = _periode;
    if (user == null) {
      setState(() => _error = 'Connectez-vous pour prendre rendez-vous.');
      return;
    }
    if (jour == null || periode == null) {
      setState(() => _error = 'Choisissez un jour et une plage horaire.');
      return;
    }
    if (_periodePassee(jour, periode)) {
      setState(() => _error =
          'Cette plage est déjà passée : choisissez un autre créneau.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(rendezVousRepositoryProvider).creer(
            acquereurId: user.id,
            bienId: widget.bienId,
            date: _debut(jour, periode),
            typeRDV: _type,
            lieu: _lieuTexte,
          );
      ref.invalidate(mesVisitesProvider);
      // Un rendez-vous prévu ferme la prise d'un second sur ce bien.
      ref.invalidate(conditionsReservationProvider(widget.bienId));
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
            content: Text(
                'Demande envoyée : la société confirmera votre rendez-vous')),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = ErrorHandler.messageOf(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jour = _jour;
    final prete = jour != null && _periode != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md + AppSpacing.xs,
                  AppSpacing.sm, AppSpacing.md + AppSpacing.xs, AppSpacing.xs),
              child: Row(
                children: [
                  CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: AppSpacing.md - AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prise de rendez-vous', style: AppTextStyles.h3),
                        Text(
                          [
                            if ((widget.societeNom ?? '').isNotEmpty)
                              widget.societeNom!,
                            widget.bienLabel,
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md + AppSpacing.xs,
                    AppSpacing.md - AppSpacing.xs,
                    AppSpacing.md + AppSpacing.xs,
                    AppSpacing.lg),
                children: [
                  _titre('Lieu de rencontre'),
                  Row(
                    children: [
                      Expanded(
                        child: _LieuCard(
                          icon: Icons.business_rounded,
                          titre: (widget.societeNom ?? '').isNotEmpty
                              ? 'Au siège ${widget.societeNom}'
                              : 'Au siège',
                          sous: 'Rendez-vous en agence',
                          selected: _type == 'SIEGE',
                          onTap: () => setState(() => _type = 'SIEGE'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                      Expanded(
                        child: _LieuCard(
                          icon: Icons.place_rounded,
                          titre: 'Sur le chantier',
                          sous: (widget.chantierLabel ?? '').isNotEmpty
                              ? widget.chantierLabel!
                              : 'Visite sur site',
                          selected: _type == 'CHANTIER',
                          onTap: () => setState(() => _type = 'CHANTIER'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: _titre('Choisir le jour', bottom: 0)),
                      Text(
                        _moisAffiche(),
                        style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryOcre),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _jours.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        final d = _jours[i];
                        final on = jour != null && d == jour;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _jour = d;
                            // Si la plage choisie est déjà passée aujourd'hui, on la désélectionne.
                            if (_periode != null &&
                                _periodePassee(d, _periode!)) {
                              _periode = null;
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 62,
                            decoration: BoxDecoration(
                              color: on ? null : AppColors.white,
                              gradient: on ? AppGradients.cta : null,
                              borderRadius: AppRadius.radiusXl,
                              border: on
                                  ? null
                                  : Border.all(color: AppColors.borderLight),
                              boxShadow: on ? AppShadows.cta : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_joursCourts[d.weekday - 1],
                                    style: AppTextStyles.overline.copyWith(
                                        color: on
                                            ? AppColors.primaryOcreSoft
                                            : AppColors.textSecondary)),
                                const SizedBox(height: AppSpacing.xs),
                                Text('${d.day}',
                                    style: AppTextStyles.h2.copyWith(
                                        color: on
                                            ? AppColors.white
                                            : AppColors.primaryBlueAnthracite)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  _titre('Créneau horaire'),
                  Row(
                    children: [
                      for (final p in RdvPeriode.values) ...[
                        if (p != RdvPeriode.values.first)
                          const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
                        Expanded(
                          child: _PeriodeButton(
                            periode: p,
                            selected: _periode == p,
                            enabled: jour != null && !_periodePassee(jour, p),
                            onTap: () => setState(() => _periode = p),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (jour == null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text('Choisissez d\'abord un jour.',
                          style: AppTextStyles.bodySmall),
                    ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.primaryOcre,
                                shape: BoxShape.circle)),
                        const SizedBox(width: AppSpacing.md - AppSpacing.xs),
                        Expanded(
                            child: Text('Visite — ${widget.bienLabel}',
                                style: AppTextStyles.cardTitle
                                    .copyWith(fontSize: 14))),
                      ],
                    ),
                  ),
                  if (prete) ...[
                    const SizedBox(height: 16),
                    _Recap(
                      date: DateFormatter.dateLongue(jour),
                      periode: _periode!,
                      lieu: _lieuTexte,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!,
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w700)),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl)),
                boxShadow: AppShadows.floating,
              ),
              child: SizedBox(
                width: double.infinity,
                child: DetailButton(
                  label: 'Confirmer le rendez-vous',
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: prete ? _submit : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _moisAffiche() {
    final d = _jour ?? _jours.first;
    return '${_moisNoms[d.month - 1]} ${d.year}';
  }

  Widget _titre(String t, {double bottom = AppSpacing.sm + AppSpacing.xxs}) =>
      Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Text(t, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
      );
}

class _LieuCard extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String sous;
  final bool selected;
  final VoidCallback onTap;

  const _LieuCard(
      {required this.icon,
      required this.titre,
      required this.sous,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
        constraints: const BoxConstraints(minHeight: 108),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
              color: selected ? AppColors.primaryOcre : AppColors.borderLight,
              width: selected ? 2 : 1),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryOcreSoft
                        : AppColors.backgroundOffWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      size: 20,
                      color: selected
                          ? AppColors.primaryOcre
                          : AppColors.textSecondary),
                ),
                const Spacer(),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      size: 20, color: AppColors.primaryOcre),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            Text(titre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
            const SizedBox(height: AppSpacing.xxs),
            Text(sous,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.primaryOcre
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PeriodeButton extends StatelessWidget {
  final RdvPeriode periode;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _PeriodeButton(
      {required this.periode,
      required this.selected,
      required this.enabled,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? AppColors.white
        : (enabled ? AppColors.primaryBlueAnthracite : AppColors.grey400);
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 64,
          decoration: BoxDecoration(
            color: selected ? null : AppColors.white,
            gradient: selected ? AppGradients.cta : null,
            borderRadius: AppRadius.radiusXl,
            border: selected ? null : Border.all(color: AppColors.borderLight),
            boxShadow: selected ? AppShadows.cta : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(periode.libelle,
                  style: AppTextStyles.cardTitle
                      .copyWith(fontSize: 15, color: fg)),
              const SizedBox(height: AppSpacing.xxs),
              Text(periode.horaires,
                  style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primaryOcreSoft
                          : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Recap extends StatelessWidget {
  final String date;
  final RdvPeriode periode;
  final String lieu;

  const _Recap({required this.date, required this.periode, required this.lieu});

  @override
  Widget build(BuildContext context) {
    final d =
        date.isEmpty ? date : '${date[0].toUpperCase()}${date.substring(1)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
      decoration: BoxDecoration(
        gradient: AppGradients.navy,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.primaryOcre, shape: BoxShape.circle)),
              const SizedBox(width: AppSpacing.sm),
              Text('RÉCAPITULATIF DU RENDEZ-VOUS',
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.onDarkMuted)),
            ],
          ),
          const SizedBox(height: AppSpacing.md - AppSpacing.xs),
          Text(d, style: AppTextStyles.h3.copyWith(color: AppColors.white)),
          const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
          Text('${periode.libelle} · ${periode.horaires}',
              style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOcreLight)),
          const SizedBox(height: AppSpacing.xs),
          Text(lieu,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onDarkMuted)),
        ],
      ),
    );
  }
}
