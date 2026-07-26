import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';

class SignageAdPreviewWidget extends StatelessWidget {
  final String? mediaUrl;
  final PlatformFile? pickedFile;
  final String mediaType;
  final String? caption;
  final String? targetVenue;

  const SignageAdPreviewWidget({
    super.key,
    this.mediaUrl,
    this.pickedFile,
    required this.mediaType,
    this.caption,
    this.targetVenue,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedia = (mediaUrl != null && mediaUrl!.isNotEmpty) || (pickedFile != null && pickedFile!.bytes != null);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: const Color(0xFF0F121C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Media Content Container
            Positioned.fill(
              child: _buildMediaContent(hasMedia),
            ),

            // Top Status Bar (Venue Target & Sponsored Badge)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          targetVenue != null && targetVenue!.isNotEmpty
                              ? 'LIVE ON: ${targetVenue!.toUpperCase()}'
                              : 'SIGNAGE DISPLAY PREVIEW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SPONSORED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Branding Overlay Bar with Night Track Logo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.92),
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Brand Badge (Night Track TV Logo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryColor, accentPurple],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tv_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'NIGHT TRACK TV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Caption / Title snippet
                    Expanded(
                      child: Text(
                        caption != null && caption!.isNotEmpty
                            ? caption!
                            : 'Promotional Ad Content Display',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(bool hasMedia) {
    if (!hasMedia) {
      return Container(
        color: const Color(0xFF141724),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tv_outlined,
                  size: 40,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Night Track TV Signage Frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload a video or banner to preview TV display layout',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (pickedFile != null && pickedFile!.bytes != null) {
      if (mediaType == 'image') {
        return Image.memory(
          pickedFile!.bytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
      } else {
        return Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_fill_rounded,
                    size: 54, color: primaryColor),
                const SizedBox(height: 8),
                Text(
                  pickedFile!.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Video Ready for Night Track TV',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (mediaUrl != null && mediaUrl!.isNotEmpty) {
      if (mediaType == 'image') {
        return Image.network(
          mediaUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
      } else {
        return Container(
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library_rounded,
                    size: 54, color: primaryColor),
                SizedBox(height: 8),
                Text(
                  'Cloud Video Stream Ready',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    }

    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.white30, size: 40),
      ),
    );
  }
}
