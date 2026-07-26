import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/ad_campaign_model.dart';
import 'campaign_status_badge.dart';

class MobileCampaignCard extends StatelessWidget {
  final AdCampaign campaign;

  const MobileCampaignCard({
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
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: Colors.white10,
                child: const Icon(Icons.broken_image, color: Colors.white30),
              ),
            )
          : Container(
              width: 70,
              height: 70,
              color: Colors.black26,
              child: const Icon(Icons.video_collection, color: Colors.white60),
            ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              thumbnailWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${campaign.organizationName ?? campaign.organizationId}',
                      style: const TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    CampaignStatusBadge(
                      status: campaign.status,
                      label: campaign.statusText,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dateFormat.format(campaign.startDate)} - ${dateFormat.format(campaign.endDate)}',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hours: ${campaign.startTime} - ${campaign.endTime}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Every ${campaign.frequencyMinutes}m for ${campaign.displayDurationSeconds}s',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${campaign.budget.toStringAsFixed(2)} ETB',
                    style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${campaign.impressionCount} Impr.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
