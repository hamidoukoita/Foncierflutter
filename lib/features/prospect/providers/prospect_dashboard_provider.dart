import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/bien_foncier_model.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/data/providers/repository_providers.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/catalogue/domain/programme_foncier.dart';

class ProspectDashboardState {
  final List<ProgrammeFoncier> programmes;
  final List<BienFoncierModel> catalogue;
  final List<ReservationModel> mesReservations;
  final bool isLoading;
  final String? error;
  final String filtreType;

  const ProspectDashboardState({
    this.programmes = const [],
    this.catalogue = const [],
    this.mesReservations = const [],
    this.isLoading = false,
    this.error,
    this.filtreType = 'TOUT',
  });

  List<BienFoncierModel> get catalogueFiltree {
    if (filtreType == 'TOUT') return catalogue;
    return catalogue.where((b) {
      final type = (b.typeBien ?? '').toUpperCase();
      if (filtreType == 'LOT_PROGRAMME' || filtreType == 'LOTS') {
        return type.contains('LOT') || b.numeroLot != null;
      }
      if (filtreType == 'PARCELLE_INDIVIDUELLE' || filtreType == 'PARCELLES') {
        return type.contains('PARCELLE') || b.numeroTitreFoncier != null;
      }
      return true;
    }).toList();
  }

  ProspectDashboardState copyWith({
    List<ProgrammeFoncier>? programmes,
    List<BienFoncierModel>? catalogue,
    List<ReservationModel>? mesReservations,
    bool? isLoading,
    String? error,
    String? filtreType,
    bool clearError = false,
  }) {
    return ProspectDashboardState(
      programmes: programmes ?? this.programmes,
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
  Future<ProspectDashboardState> build() async => _fetchData();

  Future<ProspectDashboardState> _fetchData() async {
    final user = ref.read(authProvider).user;
    if (user == null) throw Exception('Utilisateur non connecté');

    final bienRepo = ref.read(bienFoncierRepositoryProvider);
    final reservationRepo = ref.read(reservationRepositoryProvider);
    final programmeRepo = ref.read(programmeRepositoryProvider);

    try {
      final results = await Future.wait<dynamic>([
        programmeRepo.getAll(),
        bienRepo.getParcelles(),
        bienRepo.getLotsProgrammes(),
        reservationRepo.getReservationsByAcquereur(user.id),
      ]);

      final programmes = results[0] as List<ProgrammeFoncier>;
      final parcelles = results[1] as List<BienFoncierModel>;
      final lots = results[2] as List<BienFoncierModel>;
      final reservations = results[3] as List<ReservationModel>;

      return ProspectDashboardState(
        programmes: programmes,
        catalogue: [...lots, ...parcelles],
        mesReservations: reservations,
      );
    } catch (e) {
      throw Exception('Erreur lors du chargement des données : $e');
    }
  }

  Future<void> refresh() async {
    final previousFilter = state.valueOrNull?.filtreType ?? 'TOUT';
    state = const AsyncValue.loading();
    try {
      final data = await _fetchData();
      state = AsyncValue.data(data.copyWith(filtreType: previousFilter));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setFiltreType(String type) {
    final current = state.valueOrNull;
    if (current != null) state = AsyncValue.data(current.copyWith(filtreType: type));
  }

  Future<bool> reserverBien(int bienId) async {
    final user = ref.read(authProvider).user;
    if (user == null) return false;

    try {
      await ref.read(reservationRepositoryProvider).reserverBien(bienId, user.id);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final prospectDashboardProvider =
    AsyncNotifierProvider<ProspectDashboardNotifier, ProspectDashboardState>(
  ProspectDashboardNotifier.new,
);
