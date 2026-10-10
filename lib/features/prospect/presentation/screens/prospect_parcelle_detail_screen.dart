import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/currency_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/reservation_actions.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/presentation/widgets/rdv_booking_sheet.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_data_providers.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/media_gallery.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/reservation_rule_banner.dart';

/// Fiche d'une parcelle : photos / 360°, caractéristiques, équipements, réservation et visite.
class ProspectParcelleDetailScreen extends ConsumerStatefulWidget {
  final int parcelleId;

  const ProspectParcelleDetailScreen({super.key, required this.parcelleId});

  @override
  ConsumerState<ProspectParcelleDetailScreen> createState() => _ProspectParcelleDetailScreenState();
}

class _ProspectParcelleDetailScreenState extends ConsumerState<ProspectParcelleDetailScreen> {
  bool _reserving = false;

  Future<void> _reserver(BienFoncierModel b) async {
    setState(() => _reserving = true);
    await reserverBienAvecConfirmation(context, ref, bienId: b.id, libelle: b.designation);
    if (mounted) setState(() => _reserving = false);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bienDetailProvider(widget.parcelleId));

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(title: const Text('Détail de la parcelle')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
        error: (e, _) => EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Parcelle introuvable',
          message: ErrorHandler.messageOf(e),
          onRetry: () => ref.invalidate(bienDetailProvider(widget.parcelleId)),
        ),
        data: (b) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MediaGallery(bienId: b.id),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.designation,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlueAnthracite,
                    ),
                  ),
                  if (b.societeNom != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      b.societeNom!,
                      style: const TextStyle(color: AppColors.primaryOcre, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _line('Statut', _statutLibelle(b.statut)),
                  _line('Prix', CurrencyFormatter.fcfa(b.prix)),
                  _line('Surface', '${b.superficie.toStringAsFixed(0)} m²'),
                  if (b.facade != null) _line('Façade', '${b.facade} m'),
                  if (b.profondeur != null) _line('Profondeur', '${b.profondeur} m'),
                  if (b.numeroTitreFoncier != null) _line('Titre foncier', b.numeroTitreFoncier!),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Équipements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _equip('Eau (SOMAPEP)', b.eauSomapep == true),
                      _equip('Électricité (EDM)', b.electriciteEdm == true),
                      _equip('Voie bitumée', b.voieBitumee == true),
                      _equip('Mur de clôture', b.murCloture == true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ReservationRuleBanner(reservationMultiple: b.reservationMultiple, isReserve: b.isReserve),
            const SizedBox(height: 20),
            if (b.peutEtreReserve) ...[
              PrimaryButton(
                text: _reserving ? 'Réservation…' : 'Réserver cette parcelle',
                isLoading: _reserving,
                onPressed: _reserving ? null : () => _reserver(b),
              ),
              const SizedBox(height: 10),
            ],
            PrimaryButton(
              text: 'Prendre rendez-vous',
              isSecondary: true,
              onPressed: () => RdvBookingSheet.show(
                context,
                bienId: b.id,
                societeId: b.societeId,
                bienLabel: b.designation,
              ),
            ),
            if (!b.peutEtreReserve) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cette parcelle n\'est pas réservable pour le moment.',
                  style: TextStyle(color: AppColors.grey600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statutLibelle(String s) {
    switch (s.toUpperCase()) {
      case 'DISPONIBLE':
        return 'Disponible';
      case 'RESERVER':
        return 'Réservée';
      case 'VENDUE':
        return 'Vendue';
      case 'INDISPONIBLE':
        return 'Indisponible';
      default:
        return s;
    }
  }

  Widget _equip(String label, bool present) {
    final color = present ? AppColors.successGreen : AppColors.grey500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(present ? Icons.check_circle_rounded : Icons.cancel_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
