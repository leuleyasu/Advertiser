import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/ad_campaign_model.dart';
import 'campaign_status_badge.dart';

class DesktopCampaignCard extends StatelessWidget {
  final AdCampaign campaign;

  const DesktopCampaignCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    final thumbnailWidget = ClipRRect(
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
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          thumbnailWidget,
          const SizedBox(width: 24),
          // Campaign Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Target: ${campaign.organizationName ?? campaign.organizationId}',
                  style: const TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  campaign.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13),
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
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hours: ${campaign.startTime} - ${campaign.endTime}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: Colors.white30, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Every ${campaign.frequencyMinutes}m for ${campaign.displayDurationSeconds}s',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11),
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
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${campaign.impressionCount} Impressions',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Status Badge
          CampaignStatusBadge(
            status: campaign.status,
            label: campaign.statusText,
          ),
        ],
      ),
    );
  }
}
