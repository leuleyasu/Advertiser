import 'package:flutter/material.dart';
import '../../../../core/models/ad_campaign_model.dart';

class CampaignStatusBadge extends StatelessWidget {
  final CampaignStatus status;
  final String label;

  const CampaignStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
