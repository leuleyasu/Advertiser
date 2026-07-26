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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation Bar (Inline)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.campaign_rounded, color: primaryColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HoursSignage',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Advertiser Portal',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!isMobile) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, color: primaryColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                campaignService.currentUserEmail ?? '',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: cardBackgroundColor,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                        tooltip: 'Sign Out',
                        onPressed: () {
                          context.read<AuthBloc>().add(const LogoutRequestedEvent());
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
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
