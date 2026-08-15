import 'package:advertiser/features/auth/bloc/auth_bloc.dart';
import 'package:advertiser/features/auth/bloc/auth_event.dart';
import 'package:advertiser/features/campaign_creation/presentation/screens/create_campaign_wizard.dart';
import 'package:advertiser/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';
import '../../../../core/services/ad_campaign_service.dart';
import '../widgets/active_organizations_section.dart';
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

class _AdvertiserDashboardView extends StatefulWidget {
  final AdCampaignService campaignService;

  const _AdvertiserDashboardView({required this.campaignService});

  @override
  State<_AdvertiserDashboardView> createState() =>
      _AdvertiserDashboardViewState();
}

class _AdvertiserDashboardViewState extends State<_AdvertiserDashboardView> {
  int _selectedNavIndex = 0;

  void _openCreateCampaignWizard(BuildContext context,
      {Organization? selectedOrg, List<Organization>? selectedOrgs}) {
    final dashboardCubit = context.read<DashboardCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CreateCampaignWizard(
        campaignService: widget.campaignService,
        initialOrg: selectedOrg,
        initialOrgs: selectedOrgs,
        onComplete: () {
          Navigator.of(dialogContext).pop();
          dashboardCubit.loadMetrics();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Campaign request distributed successfully! Pending venue admin approval.'),
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
    final isDesktop = size.width >= 900;
    final isMobile = size.width < 700;

    if (isDesktop) {
      // Desktop / Web: Permanent Left Side Menu + Main Content Canvas
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            // Left Navigation Side Menu (Sidebar)
            _buildDesktopSideMenu(context),

            // Main Content Area
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
                    // Top App Header
                    _buildTopHeader(isMobile: false),

                    // Page Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        child: _buildPageContent(
                            isDesktop: true, isMobile: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile / Tablet: Top Bar + Drawer + Bottom Navigation Bar
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF131022),
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                _getNavTitle(_selectedNavIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: primaryColor),
              tooltip: 'New Campaign',
              onPressed: () => _openCreateCampaignWizard(context),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 20),
              tooltip: 'Sign Out',
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequestedEvent());
              },
            ),
          ],
        ),
        drawer: _buildMobileDrawer(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: _buildPageContent(isDesktop: false, isMobile: isMobile),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131022),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedNavIndex,
            onTap: (index) {
              if (index == 3) {
                _openCreateCampaignWizard(context);
              } else {
                setState(() => _selectedNavIndex = index);
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tv_rounded),
                label: 'Venues',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.campaign_rounded),
                label: 'Campaigns',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_rounded, color: primaryColor),
                label: 'Create',
              ),
            ],
          ),
        ),
      );
    }
  }

  String _getNavTitle(int index) {
    switch (index) {
      case 1:
        return 'Venues & Screens';
      case 2:
        return 'My Campaigns';
      case 0:
      default:
        return 'ayuStream Portal';
    }
  }

  // -------------------------------------------------------------
  // Desktop Left Sidebar Menu
  // -------------------------------------------------------------
  Widget _buildDesktopSideMenu(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF110E1E),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Column(
        children: [
          // Logo & Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.campaign_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ayuStream',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'ADVERTISER PORTAL',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Action: Create Campaign Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openCreateCampaignWizard(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'New Campaign',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Menu Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSideMenuItem(
                  index: 0,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  subtitle: 'Metrics & Overview',
                ),
                const SizedBox(height: 6),
                _buildSideMenuItem(
                  index: 1,
                  icon: Icons.tv_rounded,
                  label: 'Venues & Screens',
                  subtitle: 'Explore TV Networks',
                  badge: 'LIVE',
                ),
                const SizedBox(height: 6),
                _buildSideMenuItem(
                  index: 2,
                  icon: Icons.campaign_rounded,
                  label: 'My Campaigns',
                  subtitle: 'Broadcast Schedules',
                ),
              ],
            ),
          ),

          // Bottom User Profile Card & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Signed In As',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                      Text(
                        widget.campaignService.currentUserEmail ?? 'Advertiser',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequestedEvent());
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.redAccent, size: 18),
                  tooltip: 'Sign Out',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Mobile Navigation Drawer
  // -------------------------------------------------------------
  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF131022),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.campaign_rounded,
                        color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ayuStream',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Advertiser Portal',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildSideMenuItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard Overview',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedNavIndex = 0);
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildSideMenuItem(
                    index: 1,
                    icon: Icons.tv_rounded,
                    label: 'Venues & Screens',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedNavIndex = 1);
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildSideMenuItem(
                    index: 2,
                    icon: Icons.campaign_rounded,
                    label: 'My Campaigns',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedNavIndex = 2);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Sign Out',
                  style: TextStyle(color: Colors.redAccent, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const LogoutRequestedEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenuItem({
    required int index,
    required IconData icon,
    required String label,
    String? subtitle,
    String? badge,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedNavIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        onTap: onTap ?? () => setState(() => _selectedNavIndex = index),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          color: isSelected ? primaryColor : Colors.white60,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? Colors.white60 : Colors.white38,
                  fontSize: 10,
                ),
              )
            : null,
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  // -------------------------------------------------------------
  // Top App Bar for Desktop
  // -------------------------------------------------------------
  Widget _buildTopHeader({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131022),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                _getNavTitle(_selectedNavIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 6),
                    SizedBox(width: 5),
                    Text(
                      'DOOH Screen Network Active',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        color: Color(0xFF38BDF8), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Chapa Instant Checkout',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: () => _openCreateCampaignWizard(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create Campaign',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Dynamic Page Content (Switching based on selected nav item)
  // -------------------------------------------------------------
  Widget _buildPageContent({required bool isDesktop, required bool isMobile}) {
    switch (_selectedNavIndex) {
      case 1:
        // View 1: Available Venues & Screens Network
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActiveOrganizationsSection(
              campaignService: widget.campaignService,
              onAdvertiseHere: (org) =>
                  _openCreateCampaignWizard(context, selectedOrg: org),
              onLaunchMultiVenue: () => _openCreateCampaignWizard(context),
            ),
          ],
        );

      case 2:
        // View 2: My Campaigns Management
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campaign Requests & Broadcast Schedules',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Track live playback, approval state, and target venue networks.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 20),
            CampaignsListStream(campaignService: widget.campaignService),
          ],
        );

      case 0:
      default:
        // View 0: Dashboard Overview (Hero + Metrics + Quick Venues & Campaigns)
        return Column(
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
            ActiveOrganizationsSection(
              campaignService: widget.campaignService,
              onAdvertiseHere: (org) =>
                  _openCreateCampaignWizard(context, selectedOrg: org),
              onLaunchMultiVenue: () => _openCreateCampaignWizard(context),
            ),
            const SizedBox(height: 36),
            const Text(
              'Recent Campaigns & Playback',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CampaignsListStream(campaignService: widget.campaignService),
          ],
        );
    }
  }
}
