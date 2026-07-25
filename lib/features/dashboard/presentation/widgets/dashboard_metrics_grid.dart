import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/constants.dart';
import '../../cubit/dashboard_cubit.dart';
import '../../cubit/dashboard_state.dart';
import 'metric_card.dart';

class DashboardMetricsGrid extends StatelessWidget {
  final bool isDesktop;
  final bool isMobile;

  const DashboardMetricsGrid({
    super.key,
    required this.isDesktop,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final metrics = state.metrics;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : (isMobile ? 1 : 2),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.6 : (isMobile ? 2.5 : 1.3),
          children: [
            MetricCard(
              title: 'Total Campaigns',
              value: (metrics['totalCampaigns'] ?? 0).toString(),
              icon: Icons.grid_view_rounded,
              color: primaryColor,
            ),
            MetricCard(
              title: 'Active Schedules',
              value: (metrics['activeCampaigns'] ?? 0).toString(),
              icon: Icons.check_circle_outline_rounded,
              color: Colors.greenAccent,
            ),
            MetricCard(
              title: 'Spent Budget',
              value: currencyFormat.format(metrics['budgetSpent'] ?? 0.0),
              icon: Icons.monetization_on_outlined,
              color: Colors.amberAccent,
            ),
            MetricCard(
              title: 'Total Impressions',
              value: (metrics['totalImpressions'] ?? 0).toString(),
              icon: Icons.visibility_outlined,
              color: accentPurple,
            ),
          ],
        );
      },
    );
  }
}
