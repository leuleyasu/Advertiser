import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';

class DashboardHeader extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onNewCampaignPressed;

  const DashboardHeader({
    super.key,
    required this.isMobile,
    required this.onNewCampaignPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your scheduled ads and monitor display metrics in real-time.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onNewCampaignPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Campaign',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your scheduled ads and monitor display metrics in real-time.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: onNewCampaignPressed,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Campaign',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
