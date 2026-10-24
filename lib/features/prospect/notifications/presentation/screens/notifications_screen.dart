import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/date_formatter.dart';
import 'package:flutter_mobile_prospect_agent/data/models/notification_model.dart';
import 'package:flutter_mobile_prospect_agent/features/prospect/construction/construction_routes.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/back_title_header.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/empty_state_view.dart';
import '../../providers/notifications_providers.dart';

/// Toutes les notifications de l'acquéreur ; une notification touchée est lue et ouvre ce qu'elle concerne.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const String _routeReservations = '/prospect/reservations';

  Future<void> _ouvrir(BuildContext context, WidgetRef ref, NotificationModel n) async {
    ref.read(mesNotificationsProvider.notifier).marquerLue(n).ignore();
    switch (n.cibleType) {
      case 'PROJET_CONSTRUCTION' when n.cibleId != null:
        context.push(ConstructionRoutes.detail(n.cibleId!));
      case 'RESERVATION':
        context.go(_routeReservations);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mesNotificationsProvider);
    final nonLues = ref.watch(notificationsNonLuesProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal, AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(
                children: [
                  const Expanded(child: BackTitleHeader(title: 'Notifications')),
                  if (nonLues > 0)
                    TextButton(
                      onPressed: () => ref.read(mesNotificationsProvider.notifier).toutMarquerLu(),
                      child: const Text('Tout marquer lu'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOcre)),
                error: (e, _) => EmptyStateView(
                  icon: Icons.cloud_off_rounded,
                  title: 'Notifications indisponibles',
                  message: ErrorHandler.messageOf(e),
                  onRetry: () => ref.invalidate(mesNotificationsProvider),
                ),
                data: (liste) => RefreshIndicator(
                  color: AppColors.primaryOcre,
                  onRefresh: () => ref.refresh(mesNotificationsProvider.future),
                  child: liste.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: AppSpacing.xxl),
                            EmptyStateView(
                              icon: Icons.notifications_none_rounded,
                              title: 'Aucune notification',
                              message: 'Les réponses des promoteurs et le suivi de vos dossiers apparaîtront ici.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageHorizontal, AppSpacing.lg, AppSpacing.pageHorizontal, AppSpacing.xl),
                          itemCount: liste.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, i) => _CarteNotification(
                            notification: liste[i],
                            onTap: () => _ouvrir(context, ref, liste[i]),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteNotification extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _CarteNotification({required this.notification, required this.onTap});

  IconData get _icone => switch (notification.cibleType) {
        'PROJET_CONSTRUCTION' => Icons.engineering_outlined,
        'RESERVATION' => Icons.bookmark_outline_rounded,
        _ when (notification.typeNotificationLibelle ?? '').toLowerCase().contains('visite') =>
          Icons.event_outlined,
        _ => Icons.notifications_none_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final nonLue = !n.lue;
    return Material(
      color: nonLue ? AppColors.primaryOcreSoft.withValues(alpha: 0.55) : AppColors.white,
      borderRadius: AppRadius.radiusLg,
      child: InkWell(
        borderRadius: AppRadius.radiusLg,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xxs),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: nonLue ? AppColors.primaryOcreLight : AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: nonLue ? AppColors.white : AppColors.backgroundOffWhite,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icone, size: 20, color: nonLue ? AppColors.primaryOcre : AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.titre,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryBlueAnthracite,
                                fontWeight: nonLue ? FontWeight.w800 : FontWeight.w600,
                              )),
                        ),
                        if (nonLue)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppSpacing.xs),
                            decoration: const BoxDecoration(color: AppColors.primaryOcre, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(n.message, style: AppTextStyles.bodySmall.copyWith(height: 1.4)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${DateFormatter.date(n.dateEnvoi)} · ${DateFormatter.heure(n.dateEnvoi)}',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
