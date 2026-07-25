import 'package:advertiser/features/auth/bloc/auth_bloc.dart';
import 'package:advertiser/features/auth/bloc/auth_event.dart';
import 'package:advertiser/features/campaign_creation/presentation/screens/create_campaign_wizard.dart';
import 'package:advertiser/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/services/ad_campaign_service.dart';
import '../widgets/campaigns_list_stream.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_metrics_grid.dart';

class AdvertiserDashboardScreen extends StatelessWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignService = AdCampaignService();

    return BlocProvider<DashboardCubit>(
      create: (_) => DashboardCubit(campaignService)..loadMetrics(),
      child: _AdvertiserDashboardView(campaignService: campaignService),
    );
  }
}

class _AdvertiserDashboardView extends StatelessWidget {
  final AdCampaignService campaignService;

  const _AdvertiserDashboardView({required this.campaignService});

  void _openCreateCampaignWizard(BuildContext context) {
    final dashboardCubit = context.read<DashboardCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CreateCampaignWizard(
        campaignService: campaignService,
        onComplete: () {
          Navigator.of(dialogContext).pop();
          dashboardCubit.loadMetrics();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Campaign requested successfully! Pending admin approval.'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.campaign_rounded, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Text(
              isMobile ? 'Console' : 'Advertiser Console',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (!isMobile) ...[
                  Text(
                    campaignService.currentUserEmail ?? '',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                ],
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  tooltip: 'Sign Out',
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequestedEvent());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(
              isMobile: isMobile,
              onNewCampaignPressed: () => _openCreateCampaignWizard(context),
            ),
            const SizedBox(height: 24),
            DashboardMetricsGrid(
              isDesktop: isDesktop,
              isMobile: isMobile,
            ),
            const SizedBox(height: 32),
            const Text(
              'Campaign Requests & Schedules',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CampaignsListStream(campaignService: campaignService),
          ],
        ),
      ),
    );
  }
}
