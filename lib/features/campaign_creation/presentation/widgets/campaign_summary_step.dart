import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/utils/format_utils.dart';

class CampaignSummaryStep extends StatelessWidget {
  final String? uploadedMediaUrl;
  final String mediaType;
  final String title;
  final String organizationName;
  final DateTimeRange? dateRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int frequencyMinutes;
  final int displayDuration;
  final double calculatedBudget;

  const CampaignSummaryStep({
    super.key,
    required this.uploadedMediaUrl,
    required this.mediaType,
    required this.title,
    required this.organizationName,
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

    final mediaWidget = (uploadedMediaUrl != null && mediaType == 'image')
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              uploadedMediaUrl!,
              width: isMobile ? 120 : 180,
              height: isMobile ? 120 : 180,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: isMobile ? 120 : 180,
            height: isMobile ? 120 : 180,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.video_collection,
                  color: Colors.white54, size: 40),
            ),
          );

    final detailsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Target Organization: $organizationName',
          style: const TextStyle(
              color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        if (dateRange != null)
          Text(
            'Dates: ${FormatUtils.formatDateRange(dateRange)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        Text(
          'Hours: ${startTime.format(context)} - ${endTime.format(context)}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Text(
          'Frequency: Every $frequencyMinutes minutes for $displayDuration seconds',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTIMATED BUDGET',
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
          'Campaign Summary & Budget Estimation',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: mediaWidget),
                  const SizedBox(height: 16),
                  detailsWidget,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mediaWidget,
                  const SizedBox(width: 24),
                  Expanded(child: detailsWidget),
                ],
              ),
      ],
    );
  }
}
