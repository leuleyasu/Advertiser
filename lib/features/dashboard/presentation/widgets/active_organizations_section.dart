import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';
import '../../../../core/services/ad_campaign_service.dart';
import 'venue_details_side_sheet.dart';

class ActiveOrganizationsSection extends StatefulWidget {
  final AdCampaignService campaignService;
  final ValueChanged<Organization> onAdvertiseHere;
  final VoidCallback? onLaunchMultiVenue;

  const ActiveOrganizationsSection({
    super.key,
    required this.campaignService,
    required this.onAdvertiseHere,
    this.onLaunchMultiVenue,
  });

  @override
  State<ActiveOrganizationsSection> createState() =>
      _ActiveOrganizationsSectionState();
}

class _ActiveOrganizationsSectionState
    extends State<ActiveOrganizationsSection> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Organization>>(
      stream: widget.campaignService.streamOrganizations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final orgs = snapshot.data ?? [];
        if (orgs.isEmpty) {
          return _buildEmptyState();
        }

        final categories = [
          'All',
          ...orgs.map((o) => _formatCategory(o.businessType)).toSet()
        ];

        final filteredOrgs = _selectedCategory == 'All'
            ? orgs
            : orgs
                .where((o) =>
                    _formatCategory(o.businessType).toLowerCase() ==
                    _selectedCategory.toLowerCase())
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(orgs.length, context),
            const SizedBox(height: 16),
            if (categories.length > 2) ...[
              _buildCategoryFilter(categories),
              const SizedBox(height: 18),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 1;
                if (width > 1200) {
                  crossAxisCount = 3;
                } else if (width > 700) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOrgs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 220,
                  ),
                  itemBuilder: (context, index) {
                    final org = filteredOrgs[index];
                    return _VenueCard(
                      org: org,
                      onAdvertisePressed: () => widget.onAdvertiseHere(org),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(int totalCount, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Available Venues & Screen Networks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$totalCount Active',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Explore verified venue screens and broadcast ads across multiple houses simultaneously',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );

    final multiVenueButton = widget.onLaunchMultiVenue != null
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: widget.onLaunchMultiVenue,
            icon: const Icon(Icons.hub_outlined, size: 16),
            label: const Text(
              'Multi-Venue Campaign',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        : const SizedBox.shrink();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleColumn,
          if (widget.onLaunchMultiVenue != null) ...[
            const SizedBox(height: 12),
            multiVenueButton,
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleColumn),
        const SizedBox(width: 16),
        multiVenueButton,
      ],
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = cat);
                }
              },
              backgroundColor: cardBackgroundColor,
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: primaryColor, strokeWidth: 2.5),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading active venue screen networks...',
              style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unable to load venue networks',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  error,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tv_off_rounded,
                  color: Colors.white38, size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Active Venue Networks Found',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'New venue screen networks will appear here once registered.',
              style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String type) {
    if (type.isEmpty) return 'Venue';
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }
}

class _VenueCard extends StatelessWidget {
  final Organization org;
  final VoidCallback onAdvertisePressed;

  const _VenueCard({
    required this.org,
    required this.onAdvertisePressed,
  });

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
    final dailyRate = org.effectiveDailyRate;
    final weeklyRate = org.effectiveWeeklyPrice;

    return InkWell(
      onTap: () => VenueDetailsSideSheet.show(
        context: context,
        org: org,
        onSelectVenue: onAdvertisePressed,
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Top Row: Icon + Type Badge + Live indicator
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  _getVenueIcon(org.businessType),
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        org.businessType.toUpperCase(),
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Screen Live',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Base rate tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${dailyRate.toStringAsFixed(0)} ETB',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ day base',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Organization / Venue Name
          Text(
            org.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Location details
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: Colors.white.withValues(alpha: 0.4), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  org.locationName != null && org.locationName!.isNotEmpty
                      ? org.locationName!
                      : 'Addis Ababa, Ethiopia',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Rate card & broadcasting info chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '7D: ${weeklyRate.toStringAsFixed(0)} ETB',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hours: ${org.effectiveStartTime} - ${org.effectiveEndTime}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // "Advertise Here" Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAdvertisePressed,
              icon: const Icon(Icons.campaign_outlined,
                  size: 18, color: primaryColor),
              label: const Text(
                'Advertise Here',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
