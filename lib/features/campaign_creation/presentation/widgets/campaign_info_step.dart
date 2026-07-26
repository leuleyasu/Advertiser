import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';

class CampaignInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController captionController;
  final Organization? selectedOrg;
  final List<Organization> organizations;
  final ValueChanged<Organization?> onOrgChanged;

  const CampaignInfoStep({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.captionController,
    required this.selectedOrg,
    required this.organizations,
    required this.onOrgChanged,
  });

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Information',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Campaign Title (e.g. Summer Special Offer)'),
            validator: (v) => v != null && v.isNotEmpty ? null : 'Title is required',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: captionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Ad Caption / Screen Text'),
            validator: (v) => v != null && v.isNotEmpty ? null : 'Caption is required',
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          const Text(
            'Select Target Venue & Network',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose which venue screen network to broadcast your ad campaign to.',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
          const SizedBox(height: 14),
          organizations.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
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
                        'Fetching available venues & organizations...',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: organizations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final org = organizations[index];
                    final isSelected = selectedOrg?.id == org.id;

                    double dailyRate = 150.0;
                    if (org.businessType.toLowerCase() == 'nightclub') {
                      dailyRate = 250.0;
                    } else if (org.businessType.toLowerCase() == 'cafe' || org.businessType.toLowerCase() == 'gym') {
                      dailyRate = 100.0;
                    }

                    return InkWell(
                      onTap: () => onOrgChanged(org),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.black26,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.white.withOpacity(0.08),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getVenueIcon(org.businessType),
                                color: isSelected ? Colors.white : primaryColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    org.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          org.businessType.toUpperCase(),
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (org.locationName != null && org.locationName!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '• ${org.locationName}',
                                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Radio<String>(
                              value: org.id,
                              groupValue: selectedOrg?.id,
                              activeColor: primaryColor,
                              onChanged: (_) => onOrgChanged(org),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
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
}
