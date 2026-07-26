class MediaUtils {
  /// Determines media type ('video' or 'image') based on file extension
  static String resolveMediaType(String? extension) {
    if (extension == null) return 'image';
    final extLower = extension.toLowerCase();
    if (extLower == 'mp4' || extLower == 'mov' || extLower == 'avi' || extLower == 'webm') {
      return 'video';
    }
    return 'image';
  }

  /// Resolves MIME type string for file uploading
  static String resolveMimeType(String mediaType, String? extension) {
    final ext = (extension ?? 'png').toLowerCase();
    if (mediaType == 'video') {
      return 'video/mp4';
    }
    return 'image/$ext';
  }
}
