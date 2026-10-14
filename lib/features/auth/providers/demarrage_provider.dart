import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/storage/preferences_app.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';

final preferencesAppProvider =
    Provider<PreferencesApp>((ref) => PreferencesApp());

/// État du démarrage : le splash reste affiché tant que [pret] est faux.
class DemarrageState {
  final bool pret;
  final bool onboardingVu;

  const DemarrageState({this.pret = false, this.onboardingVu = false});
}

/// Charge les préférences au lancement et mémorise la fin de l'onboarding,
/// qui n'est présenté qu'à la première ouverture de l'application.
class DemarrageNotifier extends Notifier<DemarrageState> {
  /// Durée minimale du splash, pour que le logo ne fasse pas qu'un flash.
  static const Duration dureeMinimaleSplash = Duration(milliseconds: 1600);

  @override
  DemarrageState build() {
    // Un utilisateur qui s'est déjà connecté n'a plus besoin de la présentation.
    ref.listen(authProvider, (_, auth) {
      if (auth.status == AuthStatus.authenticated) terminerOnboarding();
    });
    Future.microtask(_charger);
    return const DemarrageState();
  }

  PreferencesApp get _prefs => ref.read(preferencesAppProvider);

  Future<void> _charger() async {
    final resultats = await Future.wait<Object?>([
      _prefs.onboardingVu(),
      Future<void>.delayed(dureeMinimaleSplash),
    ]);
    state = DemarrageState(pret: true, onboardingVu: resultats.first as bool);
  }

  Future<void> terminerOnboarding() async {
    if (state.onboardingVu) return;
    await _prefs.marquerOnboardingVu();
    state = DemarrageState(pret: state.pret, onboardingVu: true);
  }
}

final demarrageProvider =
    NotifierProvider<DemarrageNotifier, DemarrageState>(DemarrageNotifier.new);

/// Quitte l'onboarding vers [route] en le marquant comme vu pour les prochaines ouvertures.
void quitterOnboarding(BuildContext context, WidgetRef ref, String route) {
  final demarrage = ref.read(demarrageProvider.notifier);
  context.go(route);
  demarrage.terminerOnboarding();
}
