import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';
import '../../../../core/utils/campaign_calculator_utils.dart';
import '../../../../core/utils/format_utils.dart';

class CampaignScheduleStep extends StatelessWidget {
  final String packageTier;
  final List<Organization> selectedOrgs;
  final DateTimeRange? dateRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> selectedDays;
  final ValueChanged<String> onSelectPackageTier;
  final VoidCallback onSelectDateRange;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;
  final ValueChanged<int> onToggleDay;

  const CampaignScheduleStep({
    super.key,
    this.packageTier = 'monthly',
    this.selectedOrgs = const [],
    required this.dateRange,
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
    required this.onSelectPackageTier,
    required this.onSelectDateRange,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
    required this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final weeklyPrice = CampaignCalculatorUtils.getDynamicPackagePrice(
      packageTier: 'weekly',
      selectedOrgs: selectedOrgs,
    );
    final monthlyPrice = CampaignCalculatorUtils.getDynamicPackagePrice(
      packageTier: 'monthly',
      selectedOrgs: selectedOrgs,
    );
    final quarterlyPrice = CampaignCalculatorUtils.getDynamicPackagePrice(
      packageTier: 'quarterly',
      selectedOrgs: selectedOrgs,
    );

    final packages = [
      {
        'id': 'weekly',
        'name': '1-Week Starter',
        'duration': '7 Days',
        'price': 'ETB ${weeklyPrice.toStringAsFixed(0)}',
        'badge': 'Standard',
        'badgeColor': Colors.blueAccent,
        'icon': Icons.bolt_rounded,
        'desc': 'Ideal for weekend launches & flash events',
      },
      {
        'id': 'monthly',
        'name': '1-Month Pro',
        'duration': '30 Days',
        'price': 'ETB ${monthlyPrice.toStringAsFixed(0)}',
        'badge': '20% OFF',
        'badgeColor': Colors.greenAccent,
        'icon': Icons.rocket_launch_rounded,
        'desc': 'Most popular for continuous brand presence',
      },
      {
        'id': 'quarterly',
        'name': '3-Month Master',
        'duration': '90 Days',
        'price': 'ETB ${quarterlyPrice.toStringAsFixed(0)}',
        'badge': '35% OFF',
        'badgeColor': Colors.amberAccent,
        'icon': Icons.workspace_premium_rounded,
        'desc': 'Maximum reach with highest long-term discount',
      },
      {
        'id': 'custom',
        'name': 'Custom Plan',
        'duration': 'Custom',
        'price': 'Flexible',
        'badge': 'Flexible',
        'badgeColor': Colors.purpleAccent,
        'icon': Icons.tune_rounded,
        'desc': 'Choose specific custom dates and terms',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Advertising Package',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          selectedOrgs.length > 1
              ? 'Packages automatically bundle pricing across all ${selectedOrgs.length} selected venues.'
              : 'Choose a standardized package or customize your campaign duration.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Package Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isMobile
                ? constraints.maxWidth
                : (constraints.maxWidth - 14) / 2;

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: packages.map((pkg) {
                final isSelected = packageTier == pkg['id'];
                final badgeColor = pkg['badgeColor'] as Color;

                return InkWell(
                  onTap: () => onSelectPackageTier(pkg['id'] as String),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.15)
                          : cardBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.2),
                                blurRadius: 16,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(pkg['icon'] as IconData,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white70,
                                    size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  pkg['name'] as String,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: badgeColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                pkg['badge'] as String,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pkg['desc'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 12,
                                    color: Colors.white.withValues(alpha: 0.4)),
                                const SizedBox(width: 6),
                                Text(
                                  'Term: ${pkg['duration']}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              pkg['price'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.greenAccent
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),

        // Date Range Display & Custom Picker
        const Text(
          'Campaign Term Dates',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onSelectDateRange,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range_rounded, color: primaryColor),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatUtils.formatDateRange(dateRange),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      packageTier == 'custom'
                          ? 'Custom dates selected (Tap to modify)'
                          : 'Auto-aligned with ${packages.firstWhere((p) => p['id'] == packageTier, orElse: () => packages[1])['name']} (Tap to modify)',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.edit_calendar_rounded,
                    color: Colors.white60, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Daily Broadcast Time Window
        const Text(
          'Daily Active Broadcast Hours',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          selectedOrgs.length == 1
              ? 'Auto-configured for ${selectedOrgs.first.name} (Operating: ${selectedOrgs.first.effectiveStartTime} - ${selectedOrgs.first.effectiveEndTime})'
              : 'The TV screens will only broadcast your ad within this daily time window.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelectStartTime,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined,
                          color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Time',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11)),
                          Text(startTime.format(context),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onSelectEndTime,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.nightlight_outlined,
                          color: primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Time',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11)),
                          Text(endTime.format(context),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Active Days of Week
        const Text(
          'Active Days of Week',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayInt = index + 1;
            final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
            final isSelected = selectedDays.contains(dayInt);
            return InkWell(
              onTap: () => onToggleDay(dayInt),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: isMobile ? 40 : 46,
                height: isMobile ? 40 : 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
