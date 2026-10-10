import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/creneau_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

/// Feuille de demande de visite : type (siège / chantier), date, créneau de la société promotrice.
class RdvBookingSheet extends ConsumerStatefulWidget {
  final int bienId;
  final int? societeId;
  final String bienLabel;

  const RdvBookingSheet({
    super.key,
    required this.bienId,
    required this.societeId,
    required this.bienLabel,
  });

  static Future<void> show(
    BuildContext context, {
    required int bienId,
    required int? societeId,
    required String bienLabel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RdvBookingSheet(
        bienId: bienId,
        societeId: societeId,
        bienLabel: bienLabel,
      ),
    );
  }

  @override
  ConsumerState<RdvBookingSheet> createState() => _RdvBookingSheetState();
}

class _RdvBookingSheetState extends ConsumerState<RdvBookingSheet> {
  String _type = 'CHANTIER';
  DateTime? _date;
  CreneauModel? _creneau;
  bool _saving = false;
  String? _error;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Date de la visite',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider).user;
    final date = _date;
    final creneau = _creneau;
    if (user == null) {
      setState(() => _error = 'Connectez-vous pour demander une visite.');
      return;
    }
    if (date == null || creneau == null) {
      setState(() => _error = 'Choisissez une date et un créneau.');
      return;
    }

    final quand = DateTime(
      date.year,
      date.month,
      date.day,
      creneau.debutHeure ?? 9,
      creneau.debutMinute ?? 0,
    );
    if (quand.isBefore(DateTime.now())) {
      setState(() => _error = 'Ce créneau est déjà passé : choisissez une autre date ou un autre horaire.');
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
            creneauId: creneau.id,
            date: quand,
            typeRDV: _type,
          );
      ref.invalidate(mesVisitesProvider);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Demande de visite envoyée : la société la confirmera prochainement')),
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
    final societeId = widget.societeId;
    final creneauxAsync = societeId != null ? ref.watch(creneauxSocieteProvider(societeId)) : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Demander une visite',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite),
            ),
            const SizedBox(height: 4),
            Text(widget.bienLabel, style: const TextStyle(color: AppColors.primaryOcre, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            const Text('Lieu de la visite', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Sur le terrain'),
                  selected: _type == 'CHANTIER',
                  selectedColor: AppColors.primaryOcre.withValues(alpha: 0.2),
                  onSelected: (_) => setState(() => _type = 'CHANTIER'),
                ),
                ChoiceChip(
                  label: const Text('Au siège de la société'),
                  selected: _type == 'SIEGE',
                  selectedColor: AppColors.primaryOcre.withValues(alpha: 0.2),
                  onSelected: (_) => setState(() => _type = 'SIEGE'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickDate,
              icon: const Icon(Icons.event_rounded, color: AppColors.primaryOcre),
              label: Text(
                _date == null ? 'Choisir une date' : DateFormatter.dateLongue(_date!),
                style: const TextStyle(color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Créneau', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            if (creneauxAsync == null)
              const Text(
                'Société introuvable pour ce bien : impossible de charger les créneaux.',
                style: TextStyle(color: AppColors.errorRed, fontSize: 13),
              )
            else
              creneauxAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(color: AppColors.primaryOcre),
                ),
                error: (e, _) => Text(
                  ErrorHandler.messageOf(e),
                  style: const TextStyle(color: AppColors.errorRed, fontSize: 13),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return const Text(
                      'Cette société n\'a pas encore ouvert de créneau de visite.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final c in list)
                        ChoiceChip(
                          label: Text(c.libelle),
                          selected: _creneau?.id == c.id,
                          selectedColor: AppColors.primaryOcre.withValues(alpha: 0.2),
                          onSelected: (_) => setState(() => _creneau = c),
                        ),
                    ],
                  );
                },
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Envoyer la demande',
              isLoading: _saving,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
