import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/ad_campaign_model.dart';
import '../../../../core/services/ad_campaign_service.dart';
import '../../../../auth/cubit/auth_cubit.dart';
import '../../../../campaign_creation/presentation/screens/create_campaign_wizard.dart';

class AdvertiserDashboardScreen extends StatefulWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  State<AdvertiserDashboardScreen> createState() => _AdvertiserDashboardScreenState();
}

class _AdvertiserDashboardScreenState extends State<AdvertiserDashboardScreen> {
  final AdCampaignService _campaignService = AdCampaignService();
  Map<String, dynamic> _metrics = {
    'totalCampaigns': 0,
    'activeCampaigns': 0,
    'budgetSpent': 0.0,
    'totalImpressions': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final metrics = await _campaignService.fetchMetrics();
      setState(() {
        _metrics = metrics;
      });
    } catch (e) {
      debugPrint('Error loading metrics: $e');
    }
  }

  void _openCreateCampaignWizard() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateCampaignWizard(
        campaignService: _campaignService,
        onComplete: () {
          Navigator.of(context).pop();
          _loadMetrics();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Campaign requested successfully! Pending admin approval.'),
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
    final currencyFormat = NumberFormat.currency(symbol: '\$');

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
            const Text(
              'Advertiser Console',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // User Details / Log out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _campaignService.currentUserEmail ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  tooltip: 'Sign Out',
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your scheduled ads and monitor display metrics in real-time.',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _openCreateCampaignWizard,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Campaign', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isDesktop ? 1.6 : 1.3,
              children: [
                _buildMetricCard(
                  title: 'Total Campaigns',
                  value: _metrics['totalCampaigns'].toString(),
                  icon: Icons.grid_view_rounded,
                  color: primaryColor,
                ),
                _buildMetricCard(
                  title: 'Active Schedules',
                  value: _metrics['activeCampaigns'].toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.greenAccent,
                ),
                _buildMetricCard(
                  title: 'Spent Budget',
                  value: currencyFormat.format(_metrics['budgetSpent']),
                  icon: Icons.monetization_on_outlined,
                  color: Colors.amberAccent,
                ),
                _buildMetricCard(
                  title: 'Total Impressions',
                  value: _metrics['totalImpressions'].toString(),
                  icon: Icons.visibility_outlined,
                  color: accentPurple,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Campaigns List / Table
            const Text(
              'Campaign Requests & Schedules',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCampaignsStream(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsStream() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return StreamBuilder<List<AdCampaign>>(
      stream: _campaignService.streamMyCampaigns(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final campaigns = snapshot.data ?? [];
        if (campaigns.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                const Text(
                  'No campaigns created yet',
                  style: TextStyle(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Click "New Campaign" to create your first signage ad request.',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: campaigns.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  // Creative Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: campaign.mediaType == 'image'
                        ? Image.network(
                            campaign.mediaUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.white10,
                              child: const Icon(Icons.broken_image, color: Colors.white30),
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.black26,
                            child: const Icon(Icons.video_collection, color: Colors.white60),
                          ),
                  ),
                  const SizedBox(width: 24),
                  // Campaign Details
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Target: ${campaign.organizationName ?? campaign.organizationId}',
                          style: const TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          campaign.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Schedule Details
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dateFormat.format(campaign.startDate)} - ${dateFormat.format(campaign.endDate)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hours: ${campaign.startTime} - ${campaign.endTime}',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white30, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Every ${campaign.frequencyMinutes}m for ${campaign.displayDurationSeconds}s',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Cost / Impressions
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${campaign.budget.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${campaign.impressionCount} Impressions',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Status Badge
                  _buildStatusBadge(campaign.status, campaign.statusText),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(CampaignStatus status, String label) {
    Color color;
    switch (status) {
      case CampaignStatus.pendingApproval:
        color = Colors.orangeAccent;
        break;
      case CampaignStatus.approved:
        color = Colors.cyanAccent;
        break;
      case CampaignStatus.active:
        color = Colors.greenAccent;
        break;
      case CampaignStatus.completed:
        color = Colors.white38;
        break;
      case CampaignStatus.rejected:
        color = Colors.redAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
