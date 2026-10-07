import 'package:flutter/material.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/data/models/agent_kpi_model.dart';

class AgentKpiGrid extends StatelessWidget {
  final AgentKpiModel kpis;

  const AgentKpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildKpiCard(
          'Visites du jour',
          kpis.totalVisitesJour.toString(),
          Icons.calendar_today,
          AppColors.primaryBlueAnthracite,
        ),
        _buildKpiCard(
          'Résa en attente (24h)',
          kpis.reservationsEnAttente.toString(),
          Icons.timer,
          AppColors.ambreReservation24h,
        ),
        _buildKpiCard(
          'Résa expirées',
          kpis.reservationsExpirees.toString(),
          Icons.warning_amber,
          AppColors.errorRed,
        ),
        _buildKpiCard(
          'Résa confirmées',
          kpis.totalReservationsConfirmees.toString(),
          Icons.check_circle_outline,
          AppColors.successGreen,
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.h2.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
