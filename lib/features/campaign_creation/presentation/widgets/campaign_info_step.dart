import 'package:advertiser/features/dashboard/presentation/widgets/venue_details_side_sheet.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';
import '../../../../core/utils/campaign_calculator_utils.dart';

class CampaignInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController captionController;
  final List<Organization> selectedOrgs;
  final List<Organization> organizations;
  final ValueChanged<Organization> onToggleOrg;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;

  const CampaignInfoStep({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.captionController,
    required this.selectedOrgs,
    required this.organizations,
    required this.onToggleOrg,
    required this.onSelectAll,
    required this.onClearAll,
  });

  @override
  State<CampaignInfoStep> createState() => _CampaignInfoStepState();
}

class _CampaignInfoStepState extends State<CampaignInfoStep> {
  String _selectedCategory = 'All';

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
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

  String _formatCategory(String type) {
    if (type.isEmpty) return 'Venue';
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      ...widget.organizations
          .map((o) => _formatCategory(o.businessType))
          .toSet()
    ];

    final filteredOrgs = _selectedCategory == 'All'
        ? widget.organizations
        : widget.organizations
            .where((o) =>
                _formatCategory(o.businessType).toLowerCase() ==
                _selectedCategory.toLowerCase())
            .toList();

    double totalBaseDailyRate = 0.0;
    for (final org in widget.selectedOrgs) {
      totalBaseDailyRate += org.effectiveDailyRate;
    }

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Information',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
                'Campaign Title (e.g. Summer Promo & Product Launch)'),
            validator: (v) =>
                v != null && v.isNotEmpty ? null : 'Title is required',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.captionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Ad Caption / Screen Broadcast Text'),
            validator: (v) =>
                v != null && v.isNotEmpty ? null : 'Caption is required',
          ),
          const SizedBox(height: 24),

          // Target Venues Multi-Select Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Select Target Venues',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.selectedOrgs.isNotEmpty
                                ? primaryColor.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.selectedOrgs.isNotEmpty
                                  ? primaryColor.withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            '${widget.selectedOrgs.length} of ${widget.organizations.length} Selected',
                            style: TextStyle(
                              color: widget.selectedOrgs.isNotEmpty
                                  ? primaryColor
                                  : Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose multiple venue screens to broadcast simultaneously.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (widget.organizations.isNotEmpty)
                Row(
                  children: [
                    TextButton(
                      onPressed: widget.onSelectAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'Select All',
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: widget.onClearAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Category filter chips if more than 1 category
          if (categories.length > 2) ...[
            SingleChildScrollView(
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
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? primaryColor
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Venue List with Checkboxes
          widget.organizations.isEmpty
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: primaryColor, strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Fetching available venue screen networks...',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOrgs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final org = filteredOrgs[index];
                    final isSelected =
                        widget.selectedOrgs.any((o) => o.id == org.id);
                    final dailyRate = org.effectiveDailyRate;
                    final weeklyRate = org.effectiveWeeklyPrice;

                    return InkWell(
                      onTap: () => widget.onToggleOrg(org),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.12)
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.07),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Custom Checkbox
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.white38,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Venue Icon
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getVenueIcon(org.businessType),
                                color: isSelected ? Colors.white : primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Venue details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    org.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                              alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          org.businessType.toUpperCase(),
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (org.locationName != null &&
                                          org.locationName!.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '• ${org.locationName}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.5),
                                                fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Hours: ${org.effectiveStartTime} - ${org.effectiveEndTime} • Loop: Every ${org.effectiveFrequencyMinutes}m',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Rate tag + Info Button
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${dailyRate.toStringAsFixed(0)} ETB',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '7D: ${weeklyRate.toStringAsFixed(0)} ETB',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.45),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => VenueDetailsSideSheet.show(
                                    context: context,
                                    org: org,
                                    onSelectVenue: () =>
                                        widget.onToggleOrg(org),
                                    actionLabel: isSelected
                                        ? 'Deselect from Campaign'
                                        : 'Select for Campaign',
                                  ),
                                  icon: const Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF38BDF8),
                                    size: 20,
                                  ),
                                  tooltip: 'View Venue & Screen Details',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 16),

          // Total base rate aggregate container
          if (widget.selectedOrgs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined,
                          size: 18, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Total Base Daily Rate (${widget.selectedOrgs.length} venues):',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '${totalBaseDailyRate.toStringAsFixed(0)} ETB / day',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
