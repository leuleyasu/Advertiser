// Stub for non-web: inline checkout unavailable, return false.

Future<bool> openChapaInlineCheckout({
  required String publicKey,
  required String amount,
  required String currency,
  required String callbackUrl,
  required String returnUrl,
  String? txRef,
  String? campaignId,
  String? title,
  String? description,
}) async {
  return false;
}
