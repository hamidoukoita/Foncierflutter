import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/presentation/controllers/catalogue_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/prospect_dashboard_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

class LotDetailScreen extends ConsumerStatefulWidget {
  final int lotId;

  const LotDetailScreen({super.key, required this.lotId});

  @override
  ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends ConsumerState<LotDetailScreen> {
  bool _reserving = false;

  Future<void> _reserver() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour réserver')),
      );
      return;
    }
    setState(() => _reserving = true);
    try {
      await ref.read(reservationRepositoryProvider).reserverBien(widget.lotId, user.id);
      ref.invalidate(mesReservationsProvider);
      ref.invalidate(prospectDashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation enregistrée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec : $e'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(lotDetailProvider(widget.lotId));
    final priceFmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(title: const Text('Détail du lot')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (lot) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                      lot.displayRef,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlueAnthracite,
                      ),
                    ),
                    if (lot.programmeNom != null) ...[
                      const SizedBox(height: 4),
                      Text(lot.programmeNom!,
                          style: const TextStyle(color: AppColors.primaryOcre, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 16),
                    _line('Statut', lot.statut ?? '—'),
                    _line('Surface', lot.superficie != null ? '${lot.superficie} m²' : '—'),
                    _line('Prix', lot.prix != null ? priceFmt.format(lot.prix) : '—'),
                    if (lot.facade != null) _line('Façade', '${lot.facade} m'),
                    if (lot.profondeur != null) _line('Profondeur', '${lot.profondeur} m'),
                    if (lot.numeroIlot != null) _line('Îlot', lot.numeroIlot!),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (lot.isDisponible)
                PrimaryButton(
                  text: _reserving ? 'Réservation…' : 'Réserver ce lot',
                  onPressed: _reserving ? null : _reserver,
                  isLoading: _reserving,
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ce lot n’est pas disponible à la réservation (${lot.statut ?? '—'}).',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.grey700),
                  ),
                ),
            ],
          );
        },
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
