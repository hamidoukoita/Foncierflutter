import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../domain/lieu_carte.dart';
import '../controllers/localisation_providers.dart';
import '../widgets/localisation_indisponible.dart';
import '../widgets/localisation_map_view.dart';

/// Carte plein écran d'un bien ou d'une cité.
class LocalisationScreen extends ConsumerWidget {
  final ProviderListenable<AsyncValue<LieuCarte>> _source;
  final VoidCallback Function(WidgetRef ref) _relancer;

  LocalisationScreen.bien({super.key, required int bienId})
      : _source = localisationBienProvider(bienId),
        _relancer =
            ((ref) => () => ref.invalidate(localisationBienProvider(bienId)));

  LocalisationScreen.programme({super.key, required int programmeId})
      : _source = localisationProgrammeProvider(programmeId),
        _relancer = ((ref) =>
            () => ref.invalidate(localisationProgrammeProvider(programmeId)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: ref.watch(_source).when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOcre),
            ),
            error: (e, _) => SafeArea(
              child: EmptyStateView(
                icon: Icons.cloud_off_rounded,
                title: 'Carte indisponible',
                message: ErrorHandler.messageOf(e),
                onRetry: _relancer(ref),
              ),
            ),
            data: (lieu) => lieu.estLocalise
                ? LocalisationMapView(lieu: lieu)
                : LocalisationIndisponible(lieu: lieu),
          ),
    );
  }
}
