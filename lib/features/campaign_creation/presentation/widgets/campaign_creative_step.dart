import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/utils/format_utils.dart';

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
        const SizedBox(height: 8),
        Text(
          'Upload a banner image (JPEG/PNG) or a short video (MP4) to display on signage screen.',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              if (pickedFile != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        size: 28,
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
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: onRemoveFile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (uploadedMediaUrl == null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.08),
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
                    label: Text(isUploading ? 'Uploading...' : 'Upload Media to Cloud'),
                  )
                else
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                      SizedBox(width: 8),
                      Text('Media verified & ready.', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ] else
                InkWell(
                  onTap: onPickFile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.none),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_rounded, size: 48, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('Drag & Drop or Click to Select File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Supports PNG, JPG, MP4 (Max 15MB)', style: TextStyle(color: Colors.white38, fontSize: 12)),
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
