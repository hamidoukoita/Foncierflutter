import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Gestion uniforme chargement / erreur / données pour les écrans agent.
class AgentAsyncView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;

  const AgentAsyncView({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOcre),
      ),
      error: (error, _) => EmptyStateView(
        icon: Icons.cloud_off_rounded,
        title: 'Chargement impossible',
        message: error.toString(),
        onRetry: onRetry,
      ),
    );
  }
}
