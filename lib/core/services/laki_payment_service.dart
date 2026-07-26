import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class LakiPaymentResult {
  final bool success;
  final String? transactionId;
  final String? txRef;
  final String? checkoutUrl;
  final String message;

  LakiPaymentResult({
    required this.success,
    this.transactionId,
    this.txRef,
    this.checkoutUrl,
    required this.message,
  });
}

class LakiPaymentService {
  final FirebaseFunctions _functions;

  LakiPaymentService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Initiates a direct payment via LakiPay (STK Push / USSD prompt directly to user phone).
  /// Supported mediums: 'TELEBIRR', 'CBE', 'MPESA', 'AWASH', 'CYBERSOURCE'
  Future<LakiPaymentResult> initiateDirectPayment({
    required double amount,
    required String phoneNumber,
    required String medium,
    required String campaignTitle,
    String currency = 'ETB',
    String? txRef,
  }) async {
    try {
      final reference = txRef ?? 'ad_laki_${DateTime.now().millisecondsSinceEpoch}';

      debugPrint('💳 LakiPaymentService: Initiating $amount $currency via $medium to $phoneNumber (Ref: $reference)');

      final callable = _functions.httpsCallable('initiateLakiDirectPayment');
      final response = await callable.call({
        'amount': amount,
        'currency': currency,
        'phone_number': phoneNumber,
        'medium': medium,
        'tx_ref': reference,
        'description': 'Ad Campaign: $campaignTitle',
      });

      final rawData = response.data;
      if (rawData is Map && rawData['status'] == 'success') {
        final data = rawData['data'];
        if (data is Map) {
          final transactionId = data['transaction_id']?.toString() ?? reference;
          return LakiPaymentResult(
            success: true,
            transactionId: transactionId,
            txRef: reference,
            message: data['message']?.toString() ?? 'Payment prompt sent to $phoneNumber ($medium)',
          );
        }
      }

      final message = rawData is Map
          ? (rawData['message']?.toString() ?? 'LakiPay initiation failed')
          : 'LakiPay initiation failed';
      return LakiPaymentResult(success: false, message: message);
    } catch (e) {
      debugPrint('❌ LakiPaymentService Error: $e');
      return LakiPaymentResult(
        success: false,
        message: 'LakiPay Direct error: ${e.toString()}',
      );
    }
  }

  /// Verify payment status via polling
  Future<bool> verifyPaymentWithPolling({
    required String transactionId,
    required String purchaseId,
    Duration interval = const Duration(seconds: 3),
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final start = DateTime.now();
    while (DateTime.now().difference(start) < timeout) {
      try {
        final callable = _functions.httpsCallable('verifyLakiPayment');
        final response = await callable.call({
          'transactionId': transactionId,
          'purchaseId': purchaseId,
        });

        if (response.data != null && response.data['verified'] == true) {
          return true;
        }
      } catch (_) {}
      await Future.delayed(interval);
    }
    return false;
  }
}
