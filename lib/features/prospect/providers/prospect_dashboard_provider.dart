import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

class ProspectDashboardState {
  final List<BienFoncierModel> catalogue;
  final List<ReservationModel> mesReservations;
  final bool isLoading;
  final String? error;
  final String filtreType; // 'TOUT', 'LOTS', 'PARCELLES'

  const ProspectDashboardState({
    this.catalogue = const [],
    this.mesReservations = const [],
    this.isLoading = false,
    this.error,
    this.filtreType = 'TOUT',
  });

  ProspectDashboardState copyWith({
    List<BienFoncierModel>? catalogue,
    List<ReservationModel>? mesReservations,
    bool? isLoading,
    String? error,
    String? filtreType,
    bool clearError = false,
  }) {
    return ProspectDashboardState(
      catalogue: catalogue ?? this.catalogue,
      mesReservations: mesReservations ?? this.mesReservations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filtreType: filtreType ?? this.filtreType,
    );
  }
}

class ProspectDashboardNotifier extends AsyncNotifier<ProspectDashboardState> {
  @override
  Future<ProspectDashboardState> build() async {
    return _fetchData();
  }

  Future<ProspectDashboardState> _fetchData() async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final bienRepo = ref.read(bienFoncierRepositoryProvider);
    final resRepo = ref.read(reservationRepositoryProvider);

    try {
      final parcelles = await bienRepo.getParcelles();
      final lots = await bienRepo.getLotsProgrammes();
      final reservations = await resRepo.getReservationsByAcquereur(user.id);

      final catalogue = [...lots, ...parcelles];

      return ProspectDashboardState(
        catalogue: catalogue,
        mesReservations: reservations,
      );
    } catch (e) {
      throw Exception('Erreur lors du chargement des données : $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _fetchData();
      state = AsyncValue.data(
          data.copyWith(filtreType: state.valueOrNull?.filtreType));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setFiltreType(String type) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(filtreType: type));
    }
  }

  Future<bool> reserverBien(int bienId) async {
    final user = ref.read(authProvider).user;
    if (user == null) return false;

    try {
      final resRepo = ref.read(reservationRepositoryProvider);
      await resRepo.reserverBien(bienId, user.id);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final prospectDashboardProvider =
    AsyncNotifierProvider<ProspectDashboardNotifier, ProspectDashboardState>(
  ProspectDashboardNotifier.new,
);
