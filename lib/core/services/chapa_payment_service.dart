import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class ChapaPaymentInitResult {
  final bool success;
  final String? checkoutUrl;
  final String? txRef;
  final String? message;

  ChapaPaymentInitResult({
    required this.success,
    this.checkoutUrl,
    this.txRef,
    this.message,
  });
}

class ChapaPaymentService {
  static const String fallbackPublicKey =
      'CHAPUBK_TEST-wrS3pvd062CVaAEOtmQ9rEyUcKZWWQ0V';

  static const String cloudFunctionCallbackUrl =
      'https://us-central1-night-music-tought.cloudfunctions.net/chapaWebhook';

  static const String returnUrl =
      'https://musicq-customer.web.app/payment-return';

  final FirebaseFunctions _functions;

  ChapaPaymentService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Load public key from Firestore dynamically or fallback
  static Future<String> getPublicKey() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('chapa_config')
          .get();
      if (doc.exists) {
        final key = doc.data()?['publicKey'] as String?;
        if (key != null && key.isNotEmpty) return key;
      }
    } catch (_) {}
    return fallbackPublicKey;
  }

  /// Initiate Chapa Payment via Cloud Function
  Future<ChapaPaymentInitResult> initiatePayment({
    required double amount,
    required String currency,
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? callbackUrl,
    Map<String, dynamic>? metadata,
    String? txRef,
  }) async {
    try {
      final String reference =
          txRef ?? 'ad_chapa_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      final Map<String, dynamic> requestData = {
        'amount': amount,
        'currency': currency,
        'first_name': firstName.isNotEmpty ? firstName : 'Advertiser',
        'last_name': lastName.isNotEmpty ? lastName : 'Client',
        'email': email.isNotEmpty ? email : 'advertiser@ayustream.com',
        'tx_ref': reference,
        'callback_url': callbackUrl ?? cloudFunctionCallbackUrl,
        'return_url': returnUrl,
        'customization': {
          'title': 'ayuStream Ad Broadcast',
          'description': 'TV Screen Commercial Campaign',
        },
        'meta': {
          'userId': userId,
          'type': 'ad_campaign',
          ...?metadata,
        },
      };

      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        requestData['phone_number'] = phoneNumber.trim();
      }

      debugPrint('💳 ChapaPaymentService: Calling initiateChapaPayment with $requestData');
      final callable = _functions.httpsCallable('initiateChapaPayment');
      final response = await callable.call(requestData);

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return ChapaPaymentInitResult(
          success: true,
          checkoutUrl: data['data']?['checkout_url'],
          txRef: reference,
          message: 'Payment initialized successfully',
        );
      }

      return ChapaPaymentInitResult(
        success: false,
        txRef: reference,
        message: data?['message'] ?? 'Payment initialization failed',
      );
    } catch (e) {
      debugPrint('❌ ChapaPaymentService Exception: $e');
      return ChapaPaymentInitResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Verify Chapa Payment via Cloud Function
  Future<bool> verifyPayment({
    required String transactionId,
    String? purchaseId,
  }) async {
    try {
      final callable = _functions.httpsCallable('verifyChapaPayment');
      final response = await callable.call({
        'transactionId': transactionId,
        'purchaseId': purchaseId,
      });

      final data = response.data;
      return data != null && data['status'] == 'success';
    } catch (e) {
      debugPrint('❌ Chapa verification error: $e');
      return false;
    }
  }
}
