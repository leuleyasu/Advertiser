import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/utils/format_utils.dart';
import 'signage_ad_preview.dart';

class CampaignCreativeStep extends StatelessWidget {
  final PlatformFile? pickedFile;
  final String mediaType;
  final bool isUploading;
  final String? uploadedMediaUrl;
  final VoidCallback onPickFile;
  final VoidCallback onUploadMedia;
  final VoidCallback onRemoveFile;

  const CampaignCreativeStep({
    super.key,
    required this.pickedFile,
    required this.mediaType,
    required this.isUploading,
    required this.uploadedMediaUrl,
    required this.onPickFile,
    required this.onUploadMedia,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Advertisement Creative',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Upload a banner image (JPEG/PNG) or a short video (MP4) to display on Night Track TV screens.',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 20),

        // Live Night Track Signage Screen Preview Mockup
        SignageAdPreviewWidget(
          pickedFile: pickedFile,
          mediaUrl: uploadedMediaUrl,
          mediaType: mediaType,
        ),
        const SizedBox(height: 20),

        Center(
          child: Column(
            children: [
              if (pickedFile != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mediaType == 'video' ? Icons.video_collection_rounded : Icons.image_rounded,
                        color: primaryColor,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickedFile!.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Size: ${FormatUtils.formatFileSizeMB(pickedFile!.size)}',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: onRemoveFile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (uploadedMediaUrl == null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: isUploading ? null : onUploadMedia,
                    icon: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(isUploading ? 'Uploading Media...' : 'Confirm & Upload to Cloud'),
                  )
                else
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                      SizedBox(width: 8),
                      Text('Media uploaded & verified for Night Track TV.', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ] else
                InkWell(
                  onTap: onPickFile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_rounded, size: 42, color: primaryColor.withOpacity(0.8)),
                        const SizedBox(height: 10),
                        const Text('Click or Tap to Select Ad Media File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Supports Banner Images (PNG, JPG) & Video Ads (MP4)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
