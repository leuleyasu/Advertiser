import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'c7ophwpn';
  static const String apiKey = '848425819557384';
  static const String apiSecret = '-VIQTMe2LhpHhWpai0eMA7Xa8Fo';
  static const String uploadFolder = 'advertiser_creatives';

  /// Uploads media file (Image or Video) to Cloudinary via Signed REST API
  static Future<String> uploadMedia({
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    debugPrint('☁️ CloudinaryService: Uploading $fileName ($mimeType, ${fileBytes.length} bytes)');

    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    // 1. Generate SHA-1 Signature (parameters sorted alphabetically + apiSecret)
    final signatureString = 'folder=$uploadFolder&timestamp=$timestamp$apiSecret';
    final signatureBytes = utf8.encode(signatureString);
    final signature = sha1.convert(signatureBytes).toString();

    // 2. Build Cloudinary Endpoint URL ('auto' handles both image & video)
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

    // 3. Create Multipart Request
    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp
      ..fields['signature'] = signature
      ..fields['folder'] = uploadFolder
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

    // 4. Send request to Cloudinary
    final streamedResponse = await request.send();
    final responseData = await streamedResponse.bytesToString();
    final jsonMap = jsonDecode(responseData);

    if (streamedResponse.statusCode == 200) {
      final secureUrl = jsonMap['secure_url'] as String;
      debugPrint('✅ CloudinaryService: Successfully uploaded! URL: $secureUrl');
      return secureUrl;
    } else {
      final errorMsg = jsonMap['error']?['message'] ?? 'Unknown Cloudinary error';
      debugPrint('❌ CloudinaryService Upload Error (${streamedResponse.statusCode}): $errorMsg');
      throw Exception('Cloudinary upload failed: $errorMsg');
    }
  }
}
