import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/services/laki_payment_service.dart';

class LakiPaymentDialog extends StatefulWidget {
  final double amountETB;
  final String campaignTitle;
  final Function(String txRef, String medium) onPaymentSuccess;

  const LakiPaymentDialog({
    super.key,
    required this.amountETB,
    required this.campaignTitle,
    required this.onPaymentSuccess,
  });

  @override
  State<LakiPaymentDialog> createState() => _LakiPaymentDialogState();
}

class _LakiPaymentDialogState extends State<LakiPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final LakiPaymentService _paymentService = LakiPaymentService();

  String _selectedMedium = 'TELEBIRR';
  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;

  final List<Map<String, String>> _paymentMediums = [
    {'code': 'TELEBIRR', 'name': 'Telebirr (STK Push)', 'icon': '📲'},
    {'code': 'CBE', 'name': 'CBE Birr', 'icon': '🏦'},
    {'code': 'AWASH', 'name': 'Awash Bank Direct', 'icon': '💳'},
    {'code': 'MPESA', 'name': 'M-PESA', 'icon': '📱'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Sending payment prompt to ${_phoneController.text}...';
    });

    final result = await _paymentService.initiateDirectPayment(
      amount: widget.amountETB,
      phoneNumber: _phoneController.text.trim(),
      medium: _selectedMedium,
      campaignTitle: widget.campaignTitle,
    );

    if (result.success) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
        _statusMessage = 'Payment request sent! Please check your mobile phone to authorize ${widget.amountETB.toStringAsFixed(2)} ETB.';
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context, true);
        widget.onPaymentSuccess(result.txRef ?? 'ad_${DateTime.now().millisecondsSinceEpoch}', _selectedMedium);
      }
    } else {
      setState(() {
        _isProcessing = false;
        _isSuccess = false;
        _statusMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LakiPay Direct Checkout',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Pay instantly via Telebirr or Mobile Banking',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Total Payable Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount Payable:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(
                      '${widget.amountETB.toStringAsFixed(2)} ETB',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Select Payment Medium
              const Text('Select Payment Method', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _paymentMediums.map((m) {
                  final isSelected = _selectedMedium == m['code'];
                  return InkWell(
                    onTap: () => setState(() => _selectedMedium = m['code']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? primaryColor : Colors.white10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(m['icon']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            m['name']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Phone Number Input Field
              const Text('Mobile Phone Number', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '0912345678 or 251912345678',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, color: primaryColor),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter your mobile phone number';
                  if (val.trim().length < 9) return 'Please enter a valid Ethiopian phone number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status Message Display
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _isSuccess ? Colors.green : Colors.amber),
                  ),
                  child: Row(
                    children: [
                      Icon(_isSuccess ? Icons.check_circle : Icons.info_outline, color: _isSuccess ? Colors.greenAccent : Colors.amberAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(color: _isSuccess ? Colors.greenAccent : Colors.amberAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isProcessing ? null : _handlePayment,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'PAY ${widget.amountETB.toStringAsFixed(2)} ETB NOW',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
