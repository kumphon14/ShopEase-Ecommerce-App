import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers/payment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ManageBankDetailsScreen extends StatefulWidget {
  const ManageBankDetailsScreen({super.key});

  @override
  State<ManageBankDetailsScreen> createState() =>
      _ManageBankDetailsScreenState();
}

class _ManageBankDetailsScreenState extends State<ManageBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameCtrl;
  late TextEditingController _accountNumberCtrl;
  late TextEditingController _accountNameCtrl;
  late TextEditingController _promptPayCtrl;
  late TextEditingController _qrCodeUrlCtrl;

  String? _previewQrUrl;

  @override
  void initState() {
    super.initState();
    final bank =
        Provider.of<PaymentProvider>(context, listen: false).bankDetails;
    _bankNameCtrl = TextEditingController(text: bank.bankName);
    _accountNumberCtrl = TextEditingController(text: bank.accountNumber);
    _accountNameCtrl = TextEditingController(text: bank.accountName);
    _promptPayCtrl = TextEditingController(text: bank.promptPayId);
    _qrCodeUrlCtrl = TextEditingController(text: bank.qrCodeUrl ?? '');
    _previewQrUrl = bank.qrCodeUrl;
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    _promptPayCtrl.dispose();
    _qrCodeUrlCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<PaymentProvider>(context, listen: false).updateBankDetails(
      bankName: _bankNameCtrl.text.trim(),
      accountNumber: _accountNumberCtrl.text.trim(),
      accountName: _accountNameCtrl.text.trim(),
      promptPayId: _promptPayCtrl.text.trim(),
      qrCodeUrl: _qrCodeUrlCtrl.text.trim().isEmpty
          ? null
          : _qrCodeUrlCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Bank details saved!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    Navigator.pop(context);
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Bank Details'),
        content: const Text('Reset all fields to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PaymentProvider>(context, listen: false)
                  .resetBankDetails();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Bank Details'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Payment Preview',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _accountNameCtrl.text.isEmpty
                          ? 'Company Name'
                          : _accountNameCtrl.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bankNameCtrl.text.isEmpty
                          ? 'Bank Name'
                          : _bankNameCtrl.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _accountNumberCtrl.text.isEmpty
                            ? 'Account Number'
                            : _accountNumberCtrl.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bank info fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bank Information',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Bank Name',
                      hint: 'e.g. Kasikorn Bank (KBank)',
                      controller: _bankNameCtrl,
                      prefixIcon: Icons.account_balance,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Bank name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Account Number',
                      hint: 'e.g. 1234567890',
                      controller: _accountNumberCtrl,
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Account number is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Account Name (Company)',
                      hint: 'e.g. ShopEase Co., Ltd.',
                      controller: _accountNameCtrl,
                      prefixIcon: Icons.business,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Account name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'PromptPay ID',
                      hint: 'Phone number or Tax ID',
                      controller: _promptPayCtrl,
                      prefixIcon: Icons.qr_code,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'PromptPay ID is required'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // QR Code management
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QR Code Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter a URL pointing to your PromptPay QR image (or leave blank to use the auto-generated pattern).',
                      style: TextStyle(
                        color: AppTheme.textMediumColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'QR Code Image URL (optional)',
                      hint: 'https://example.com/qr.png',
                      controller: _qrCodeUrlCtrl,
                      prefixIcon: Icons.image_outlined,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(
                                () => _previewQrUrl = _qrCodeUrlCtrl.text,
                              );
                            },
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 16,
                            ),
                            label: const Text('Preview QR'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _qrCodeUrlCtrl.clear();
                                _previewQrUrl = null;
                              });
                            },
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Remove QR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                              side: const BorderSide(
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_previewQrUrl != null && _previewQrUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _previewQrUrl!,
                            height: 160,
                            width: 160,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, p) => p == null
                                ? child
                                : const SizedBox(
                                    height: 160,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                            errorBuilder: (_, _, _) => Container(
                              height: 160,
                              width: 160,
                              color: AppTheme.backgroundColor,
                              child: const Center(
                                child: Text(
                                  'Invalid URL',
                                  style: TextStyle(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Bank Details',
                onPressed: _save,
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}