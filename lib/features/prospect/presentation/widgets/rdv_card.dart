import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/rendez_vous_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/detail_kit.dart';

/// Carte d'un rendez-vous de visite de l'acquéreur, avec annulation tant qu'il n'est pas passé.
class RdvCard extends ConsumerStatefulWidget {
  final RendezVousModel rdv;

  const RdvCard({super.key, required this.rdv});

  @override
  ConsumerState<RdvCard> createState() => _RdvCardState();
}

class _RdvCardState extends ConsumerState<RdvCard> {
  bool _busy = false;

  Future<void> _annuler() async {
    setState(() => _busy = true);
    await annulerRendezVousAvecConfirmation(context, ref, widget.rdv.id);
    if (mounted) setState(() => _busy = false);
  }

  /// « Matinée » / « Après-midi » d'après l'heure du rendez-vous.
  static String _periode(DateTime d) => d.hour < 13 ? 'Matinée' : 'Après-midi';

  @override
  Widget build(BuildContext context) {
    final rdv = widget.rdv;
    final Color color;
    final String label;
    if (rdv.isAnnule) {
      color = AppColors.grey600;
      label = 'Annulé';
    } else if (rdv.isAccepte) {
      color = AppColors.successGreen;
      label = 'Confirmé';
    } else if (rdv.isRefuse) {
      color = AppColors.errorRed;
      label = 'Refusé';
    } else {
      color = AppColors.ambreReservation24h;
      label = 'En attente';
    }
    final titre = rdv.bienDesignation ?? rdv.bienReference ?? 'Visite';
    final peutAnnuler = !rdv.isRefuse && rdv.dateRendezVous.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryOcre.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(rdv.isChantier ? Icons.landscape_rounded : Icons.business_rounded,
                    color: AppColors.primaryOcre),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre,
                        style: const TextStyle(
                            fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryBlueAnthracite)),
                    if ((rdv.programmeNom ?? '').isNotEmpty)
                      Text(rdv.programmeNom!,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(label: label, color: color),
            ],
          ),
          const SizedBox(height: 14),
          _row(Icons.event_rounded, DateFormatter.dateLongue(rdv.dateRendezVous)),
          const SizedBox(height: 6),
          _row(Icons.schedule_rounded,
              '${_periode(rdv.dateRendezVous)} · ${DateFormatter.heure(rdv.dateRendezVous)}'),
          const SizedBox(height: 6),
          _row(
            Icons.place_outlined,
            (rdv.lieu != null && rdv.lieu!.isNotEmpty)
                ? rdv.lieu!
                : (rdv.isChantier ? 'Visite sur le terrain' : 'Rendez-vous au siège'),
          ),
          if (rdv.agentNom != null && rdv.agentNom!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.person_outline_rounded, 'Avec ${rdv.agentNom}'),
          ],
          if (rdv.isRefuse && !rdv.isAnnule && (rdv.motifRefus ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Motif : ${rdv.motifRefus}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.errorRed, fontWeight: FontWeight.w600)),
          ],
          if (peutAnnuler) ...[
            const SizedBox(height: 14),
            DetailButton(
              label: 'Annuler le rendez-vous',
              icon: Icons.close_rounded,
              danger: true,
              compact: true,
              loading: _busy,
              onPressed: _annuler,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13.5, color: AppColors.primaryBlueAnthracite, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
