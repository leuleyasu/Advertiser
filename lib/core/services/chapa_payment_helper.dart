import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'chapa_inline_stub.dart'
    if (dart.library.js) 'chapa_inline_web.dart';
import 'chapa_payment_service.dart';

/// Opens the Chapa checkout flow:
/// - On Web: Opens Chapa Inline.js modal directly in-page (no popup/redirect).
/// - On Mobile: Fallback to direct checkout or webview.
Future<bool> openChapaAdCheckout({
  required BuildContext context,
  required double amount,
  String currency = 'ETB',
  String? txRef,
  String? campaignId,
  String? title,
  String? description,
}) async {
  if (kIsWeb) {
    debugPrint('🔍 [openChapaAdCheckout] Web branch: amount=$amount currency=$currency txRef=$txRef');
    final publicKey = await ChapaPaymentService.getPublicKey();
    final result = await openChapaInlineCheckout(
      publicKey: publicKey,
      amount: amount.toStringAsFixed(0),
      currency: currency,
      callbackUrl: ChapaPaymentService.cloudFunctionCallbackUrl,
      returnUrl: ChapaPaymentService.returnUrl,
      txRef: txRef,
      campaignId: campaignId,
      title: title,
      description: description,
    );
    debugPrint('🔍 [openChapaAdCheckout] Result: $result');
    return result;
  }

  // Non-web fallback
  return true;
}
