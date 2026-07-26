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
              : DropdownButtonFormField<Organization>(
                  value: selectedOrg,
                  dropdownColor: cardBackgroundColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Target Organization / Venue'),
                  items: organizations.map((org) {
                    return DropdownMenuItem<Organization>(
                      value: org,
                      child: Text('${org.name} (${org.businessType.toUpperCase()})'),
                    );
                  }).toList(),
                  onChanged: onOrgChanged,
                ),
        ],
      ),
    );
  }
}
