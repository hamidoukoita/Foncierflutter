import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/data/models/reservation_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/providers/mes_reservations_provider.dart';
import '../../providers/suite_vente_providers.dart';
import 'choix_suite_vente_dialog.dart';

/// Propose le choix « autre bien ou remboursement » dès qu'une réservation de l'acquéreur
/// l'attend : à l'ouverture de l'application, à chaque retour au premier plan,
/// et quand la liste des réservations est rafraîchie.
class SuiteVenteEcouteur extends ConsumerStatefulWidget {
  final Widget child;

  const SuiteVenteEcouteur({super.key, required this.child});

  @override
  ConsumerState<SuiteVenteEcouteur> createState() => _SuiteVenteEcouteurState();
}

class _SuiteVenteEcouteurState extends ConsumerState<SuiteVenteEcouteur> with WidgetsBindingObserver {
  /// Réservations déjà proposées depuis la dernière ouverture (« Décider plus tard » ne relance pas aussitôt).
  final Set<int> _dejaProposees = {};
  bool _popupOuvert = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _proposer(ref.read(reservationsAChoisirProvider)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState etat) {
    if (etat == AppLifecycleState.resumed) {
      _dejaProposees.clear();
      ref.invalidate(mesReservationsProvider);
    }
  }

  Future<void> _proposer(List<ReservationModel> aChoisir) async {
    if (_popupOuvert || !mounted) return;
    final suivante = aChoisir.where((r) => !_dejaProposees.contains(r.id)).firstOrNull;
    if (suivante == null) return;
    _dejaProposees.add(suivante.id);
    _popupOuvert = true;
    await ChoixSuiteVenteDialog.afficher(context, suivante);
    _popupOuvert = false;
    // Plusieurs biens vendus : les suivants sont proposés à la suite.
    if (mounted) _proposer(ref.read(reservationsAChoisirProvider));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<ReservationModel>>(reservationsAChoisirProvider, (_, suivantes) => _proposer(suivantes));
    return widget.child;
  }
}
