import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/services/chapa_payment_helper.dart';

class ChapaPaymentDialog extends StatefulWidget {
  final double amountETB;
  final String campaignTitle;
  final int venueCount;
  final Function(String txRef) onPaymentSuccess;

  const ChapaPaymentDialog({
    super.key,
    required this.amountETB,
    required this.campaignTitle,
    required this.venueCount,
    required this.onPaymentSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required double amountETB,
    required String campaignTitle,
    required int venueCount,
    required Function(String txRef) onPaymentSuccess,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChapaPaymentDialog(
        amountETB: amountETB,
        campaignTitle: campaignTitle,
        venueCount: venueCount,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<ChapaPaymentDialog> createState() => _ChapaPaymentDialogState();
}

class _ChapaPaymentDialogState extends State<ChapaPaymentDialog> {
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _handleChapaPay() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Launching Chapa secure checkout...';
    });

    final txRef = 'ad_chapa_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final success = await openChapaAdCheckout(
        context: context,
        amount: widget.amountETB,
        currency: 'ETB',
        txRef: txRef,
        title: widget.campaignTitle,
        description: 'ayuStream DOOH (${widget.venueCount} Venues)',
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Payment successful!';
        });

        Navigator.of(context).pop();
        widget.onPaymentSuccess(txRef);
      } else {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Payment was cancelled or failed. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Payment error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 480,
        decoration: BoxDecoration(
          color: const Color(0xFF131022),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Payment with Chapa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Telebirr • CBE Birr • Awash • Bank Cards',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isProcessing)
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Amount Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.15),
                          const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Campaign Budget',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.amountETB.toStringAsFixed(2)} ETB',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.venueCount} Target Venues • ${widget.campaignTitle}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Supported Payment Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPaymentPill('Telebirr', const Color(0xFF0072CE)),
                      _buildPaymentPill('CBE Birr', const Color(0xFF8A1538)),
                      _buildPaymentPill('Awash Bank', const Color(0xFFD97706)),
                      _buildPaymentPill('Visa / Mastercard', const Color(0xFF6366F1)),
                    ],
                  ),

                  if (_statusMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handleChapaPay,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.payment_rounded, size: 20),
                      label: Text(
                        _isProcessing
                          ? 'Opening Chapa...'
                          : 'Pay ${widget.amountETB.toStringAsFixed(0)} ETB with Chapa',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
