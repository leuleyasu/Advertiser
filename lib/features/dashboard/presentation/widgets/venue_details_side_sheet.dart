import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';

class VenueDetailsSideSheet extends StatelessWidget {
  final Organization org;
  final VoidCallback? onSelectVenue;
  final String? actionLabel;

  const VenueDetailsSideSheet({
    super.key,
    required this.org,
    this.onSelectVenue,
    this.actionLabel,
  });

  /// Responsive entry point:
  /// - Desktop / Web (width >= 800): Slides in from the right edge.
  /// - Mobile / Tablet (width < 800): Slides up as a draggable Modal Bottom Sheet.
  static Future<void> show({
    required BuildContext context,
    required Organization org,
    VoidCallback? onSelectVenue,
    String? actionLabel,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      return showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss Venue Details',
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, anim1, anim2) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 460,
                height: double.infinity,
                child: VenueDetailsSideSheet(
                  org: org,
                  onSelectVenue: onSelectVenue,
                  actionLabel: actionLabel,
                ),
              ),
            ),
          );
        },
        transitionBuilder: (ctx, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.88,
          child: Material(
            color: Colors.transparent,
            child: VenueDetailsSideSheet(
              org: org,
              onSelectVenue: onSelectVenue,
              actionLabel: actionLabel,
            ),
          ),
        ),
      );
    }
  }

  IconData _getVenueIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cafe':
        return Icons.coffee_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'nightclub':
      default:
        return Icons.nightlife_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131022),
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : const BorderRadius.horizontal(left: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 30,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: SafeArea(
        top: isMobile,
        bottom: true,
        child: Column(
          children: [
            // Top Drag Handle for Mobile
            if (isMobile)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      _getVenueIcon(org.businessType),
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                org.businessType.toUpperCase(),
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Live TV Network',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          org.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  ),
                ],
              ),
            ),

            // Scrollable Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location info pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF38BDF8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              org.locationName != null && org.locationName!.isNotEmpty
                                  ? org.locationName!
                                  : 'Addis Ababa, Ethiopia',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Venue & Screen Placement Description
                    const Text(
                      'About the Venue & Screens',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1728),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        org.effectiveDescription,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Screen & Audience Specifications Grid (4 Metrics)
                    const Text(
                      'Screen & Audience Specifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      children: [
                        _buildSpecCard(
                          icon: Icons.tv_rounded,
                          label: 'TV Displays',
                          value: '${org.effectiveScreenCount}x 4K Screens',
                          color: const Color(0xFF38BDF8),
                        ),
                        _buildSpecCard(
                          icon: Icons.groups_rounded,
                          label: 'Daily Traffic',
                          value: org.effectiveFootTraffic,
                          color: const Color(0xFF10B981),
                        ),
                        _buildSpecCard(
                          icon: Icons.person_pin_circle_rounded,
                          label: 'Audience',
                          value: org.effectiveAudienceDemographic,
                          color: const Color(0xFFA855F7),
                        ),
                        _buildSpecCard(
                          icon: Icons.repeat_rounded,
                          label: 'Playback Loop',
                          value: 'Every ${org.effectiveFrequencyMinutes}m (4x/hr)',
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Broadcasting Schedule Box
                    const Text(
                      'Primetime Broadcasting Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1728),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  color: Color(0xFF38BDF8),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Display Window',
                                    style: TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                  Text(
                                    '${org.effectiveStartTime} — ${org.effectiveEndTime}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Peak Shift',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Active Rate Card & Packages
                    const Text(
                      'Advertiser Rate Card & Packages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildPackageRateRow(
                      tier: 'Daily Slot',
                      duration: '1 Day',
                      price: '${org.effectiveDailyRate.toStringAsFixed(0)} ETB',
                      tag: 'BASE',
                      color: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 8),

                    _buildPackageRateRow(
                      tier: '1-Week Starter',
                      duration: '7 Days',
                      price: '${org.effectiveWeeklyPrice.toStringAsFixed(0)} ETB',
                      tag: '10% OFF',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 8),

                    _buildPackageRateRow(
                      tier: '1-Month Pro',
                      duration: '30 Days',
                      price: '${org.effectiveMonthlyPrice.toStringAsFixed(0)} ETB',
                      tag: 'POPULAR • 20% OFF',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 8),

                    _buildPackageRateRow(
                      tier: '3-Month Master',
                      duration: '90 Days',
                      price: '${org.effectiveQuarterlyPrice.toStringAsFixed(0)} ETB',
                      tag: 'BEST VALUE • 35% OFF',
                      color: const Color(0xFFA855F7),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161327),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onSelectVenue != null) {
                      onSelectVenue!();
                    }
                  },
                  icon: const Icon(Icons.campaign_rounded, size: 20),
                  label: Text(
                    actionLabel ?? 'Advertise at ${org.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildSpecCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1728),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9.5,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageRateRow({
    required String tier,
    required String duration,
    required String price,
    required String tag,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1728),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                tier,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                duration,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
