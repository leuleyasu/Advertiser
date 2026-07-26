import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/ad_campaign_model.dart';
import '../../../../core/services/ad_campaign_service.dart';
import 'desktop_campaign_card.dart';
import 'mobile_campaign_card.dart';

class CampaignsListStream extends StatelessWidget {
  final AdCampaignService campaignService;

  const CampaignsListStream({
    super.key,
    required this.campaignService,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return StreamBuilder<List<AdCampaign>>(
      stream: campaignService.streamMyCampaigns(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SpinKitThreeBounce(color: primaryColor, size: 30));
        }

        final campaigns = snapshot.data ?? [];
        if (campaigns.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined,
                    size: 64, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                const Text(
                  'No campaigns created yet',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Click "New Campaign" to create your first signage ad request.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: campaigns.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            if (isMobile) {
              return MobileCampaignCard(campaign: campaign);
            }
            return DesktopCampaignCard(campaign: campaign);
          },
        );
      },
    );
  }
}
