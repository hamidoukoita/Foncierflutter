import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_card.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';

/// Message d'état intégré au flux de l'accueil (erreur, liste vide).
class AccueilFeedback extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const AccueilFeedback({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: EmptyStateView(
        icon: icon,
        title: title,
        message: message,
        retryLabel: actionLabel,
        onRetry: onAction,
      ),
    );
  }
}
