// Web-only: Chapa Inline.js integration for Advertiser Portal.
// Opens a payment modal inside the page — no redirect, no popup, no new tab.

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

/// Opens the Chapa inline checkout modal.
/// Returns `true` when payment succeeds, `false` otherwise.
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
  final completer = Completer<bool>();
  // ignore: avoid_print
  print(
      '🔍 [ChapaInline] openChapaInlineCheckout called: amount=$amount currency=$currency txRef=$txRef');

  // Load Chapa inline.js dynamically if not already present in DOM
  if (html.document.querySelector('script[src*="js.chapa.co"]') == null) {
    // ignore: avoid_print
    print('🔍 [ChapaInline] Script not found in DOM, loading dynamically...');
    await _loadScript('https://js.chapa.co/v1/inline.js');
    // ignore: avoid_print
    print('🔍 [ChapaInline] Dynamic script load completed');
  } else {
    // ignore: avoid_print
    print('🔍 [ChapaInline] Script already found in DOM');
  }

  // Create an overlay + container for the inline form
  final containerId = 'chapa_inline_${DateTime.now().millisecondsSinceEpoch}';
  final overlay = html.DivElement()
    ..id = '${containerId}_overlay'
    ..style.position = 'fixed'
    ..style.top = '0'
    ..style.left = '0'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.backgroundColor = 'rgba(0,0,0,0.65)'
    // ..style. = 'blur(6px)'
    ..style.zIndex = '999999'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center';

  final container = html.DivElement()
    ..id = containerId
    ..style.backgroundColor = '#131022'
    ..style.padding = '24px'
    ..style.borderRadius = '16px'
    ..style.minWidth = '340px'
    ..style.maxWidth = '90vw'
    ..style.boxShadow = '0 20px 50px rgba(0,0,0,0.8)'
    ..style.border = '1px solid rgba(255,255,255,0.1)';

  overlay.append(container);
  html.document.body!.append(overlay);
  // ignore: avoid_print
  print('🔍 [ChapaInline] Overlay + container created: $containerId');

  // Get the ChapaCheckout constructor from global window
  final chapaCtor = js.context['ChapaCheckout'];
  if (chapaCtor == null) {
    // ignore: avoid_print
    print('🔍 [ChapaInline] ❌ ChapaCheckout is NULL in js.context!');
    overlay.remove();
    completer.complete(false);
    return false;
  }

  final callbackWithParams = campaignId != null
      ? (callbackUrl.contains('?')
          ? '$callbackUrl&campaignId=$campaignId'
          : '$callbackUrl?campaignId=$campaignId')
      : callbackUrl;

  final configMap = <String, dynamic>{
    'publicKey': publicKey,
    'amount': amount,
    'currency': currency,
    'callbackUrl': callbackWithParams,
    'returnUrl': returnUrl,
    'tx_ref': txRef ?? 'ad_chapa_${DateTime.now().millisecondsSinceEpoch}',
    'customization': {
      'title': title ?? 'ayuStream Ad Campaign',
      'description': description ?? 'Commercial TV Screen Broadcast Slot',
    },
  };

  configMap.addAll({
    'onSuccessfulPayment': () {
      // ignore: avoid_print
      print('🔍 [ChapaInline] ✅ onSuccessfulPayment fired');
      if (!completer.isCompleted) completer.complete(true);
    },
    'onPaymentFailure': () {
      // ignore: avoid_print
      print('🔍 [ChapaInline] ❌ onPaymentFailure fired');
      if (!completer.isCompleted) completer.complete(false);
    },
    'onClose': () {
      // ignore: avoid_print
      print('🔍 [ChapaInline] 👋 onClose fired');
      if (!completer.isCompleted) completer.complete(false);
    },
  });

  final jsConfig = js.JsObject.jsify(configMap);
  try {
    final chapa = js.JsObject(chapaCtor, [jsConfig]);
    chapa.callMethod('initialize', [containerId]);
    // ignore: avoid_print
    print('🔍 [ChapaInline] initialize() called with container: $containerId');
  } catch (e) {
    // ignore: avoid_print
    print('🔍 [ChapaInline] ❌ Error creating/initializing ChapaCheckout: $e');
    if (!completer.isCompleted) completer.complete(false);
  }

  return completer.future.whenComplete(() {
    overlay.remove();
    // ignore: avoid_print
    print('🔍 [ChapaInline] Cleanup complete');
  });
}

Future<void> _loadScript(String src) async {
  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..src = src
    ..onLoad.listen((_) {
      if (!completer.isCompleted) completer.complete();
    })
    ..onError.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
  html.document.body!.append(script);
  return completer.future;
}
