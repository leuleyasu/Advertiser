import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';
import '../../../../core/utils/campaign_calculator_utils.dart';
import '../../../../core/utils/format_utils.dart';
import 'signage_ad_preview.dart';

class CampaignSummaryStep extends StatelessWidget {
  final String? uploadedMediaUrl;
  final String mediaType;
  final String title;
  final List<Organization> selectedOrgs;
  final DateTimeRange? dateRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String packageTier;
  final int frequencyMinutes;
  final int displayDuration;
  final double calculatedBudget;

  const CampaignSummaryStep({
    super.key,
    required this.uploadedMediaUrl,
    required this.mediaType,
    required this.title,
    required this.selectedOrgs,
    this.packageTier = 'monthly',
    required this.dateRange,
    required this.startTime,
    required this.endTime,
    required this.frequencyMinutes,
    required this.displayDuration,
    required this.calculatedBudget,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final venueNames = selectedOrgs.isEmpty
        ? 'All Venues'
        : selectedOrgs.length == 1
            ? selectedOrgs.first.name
            : '${selectedOrgs.length} Selected Venues (${selectedOrgs.map((o) => o.name).take(2).join(', ')}${selectedOrgs.length > 2 ? '...' : ''})';

    final packageName = packageTier == 'weekly'
        ? '1-Week Starter (7 Days)'
        : packageTier == 'quarterly'
            ? '3-Month Master (90 Days • 35% OFF)'
            : packageTier == 'custom'
                ? 'Custom Schedule'
                : '1-Month Pro (30 Days • 20% OFF)';

    final mediaWidget = SignageAdPreviewWidget(
      mediaUrl: uploadedMediaUrl,
      mediaType: mediaType,
      caption: title,
      targetVenue: venueNames,
    );

    final detailsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                packageName,
                style: const TextStyle(
                  color: accentPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Target Venues List
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_rounded,
                      size: 16, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'Target Venues (${selectedOrgs.length}):',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: selectedOrgs.map((org) {
                  final rate = org.effectiveDailyRate;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${org.name} (${rate.toStringAsFixed(0)} ETB/d)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (dateRange != null)
          Text(
            'Schedule Dates: ${FormatUtils.formatDateRange(dateRange)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        const SizedBox(height: 4),
        Text(
          'Display Hours: ${startTime.format(context)} - ${endTime.format(context)}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Loop Frequency: Every $frequencyMinutes minutes for $displayDuration seconds',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 14),

        // Distribution Notice
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.lightBlueAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Requests will be sent to each venue dashboard. Once approved, ads stream live to their TVs.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Budget summary box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL DISTRIBUTED CAMPAIGN BUDGET',
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                FormatUtils.formatCurrency(calculatedBudget),
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campaign Review & TV Signage Preview',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Review how your ad banner/video will appear on venue screens via Night Track TV.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mediaWidget,
                  const SizedBox(height: 16),
                  detailsWidget,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: mediaWidget),
                  const SizedBox(width: 20),
                  Expanded(flex: 6, child: detailsWidget),
                ],
              ),
      ],
    );
  }
}
