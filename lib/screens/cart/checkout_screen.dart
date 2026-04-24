import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../services/providers/auth_provider.dart';
import '../../services/providers/cart_provider.dart';
import '../../services/providers/order_provider.dart';
import '../../services/providers/payment_provider.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  PaymentMethod _selectedPayment = PaymentMethod.cod;
  bool _isPlacing = false;

  String? _attachedProofName;
  String? _attachedProofPath;

  bool get _hasAttachedProof =>
      _attachedProofPath != null && _attachedProofPath!.trim().isNotEmpty;

  Future<void> _placeOrder() async {
    if (_isPlacing) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPayment == PaymentMethod.bankTransfer && !_hasAttachedProof) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No Proof Attached'),
          content: const Text(
            'You have not uploaded a transfer slip. Place order anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }
    if (!mounted) return;

    setState(() => _isPlacing = true);

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final orders = Provider.of<OrderProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final orderId = await orders.addOrder(
        cart.items.values.toList(),
        cart.totalAmount,
        paymentMethod: _selectedPayment,
        customerName: _nameController.text.trim(),
        customerId: auth.isAuthenticated ? auth.username : 'USR001',
      );

      bool slipUploadFailed = false;
      String? slipUploadError;

      if (_hasAttachedProof) {
        try {
          await orders.attachProofOfTransfer(orderId, _attachedProofPath!);
        } catch (e) {
          slipUploadFailed = true;
          slipUploadError = e.toString();
        }
      }

      cart.clear();

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 12),
              const Text(
                'Order Placed! 🎉',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            _selectedPayment == PaymentMethod.cod
                ? 'Your order is confirmed. Pay upon delivery.'
                : _hasAttachedProof
                    ? (slipUploadFailed
                        ? 'Your order was created, but slip upload failed. Please upload your slip again later in Order History.'
                        : 'Payment slip submitted. We will verify shortly.')
                    : 'Please transfer payment and upload your slip in Order History.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMediumColor),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.mainNav,
                    (route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );

      if (slipUploadFailed && mounted) {
        _showErrorSnackBar(
          slipUploadError == null || slipUploadError.isEmpty
              ? 'Slip upload failed. Please try again later.'
              : 'Slip upload failed: $slipUploadError',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showErrorSnackBar('Checkout failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isPlacing = false);
      }
    }
  }

  Future<void> _showSlipSourcePicker() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Text(
                  'Upload Payment Slip',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(ctx, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open_outlined),
                  title: const Text('Choose from Files'),
                  onTap: () => Navigator.pop(ctx, 'files'),
                ),
                if (_hasAttachedProof)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.errorColor,
                    ),
                    title: const Text(
                      'Remove current slip',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                    onTap: () => Navigator.pop(ctx, 'remove'),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case 'gallery':
        await _pickSlipFromGallery();
        break;
      case 'files':
        await _pickSlipFromFiles();
        break;
      case 'remove':
        _removeSlip();
        break;
    }
  }

  Future<void> _pickSlipFromGallery() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) return;

      setState(() {
        _attachedProofPath = picked.path;
        _attachedProofName = picked.name;
      });

      _showSuccessSnackBar('Slip selected from gallery');
    } catch (_) {
      _showErrorSnackBar('Unable to open gallery');
    }
  }

  Future<void> _pickSlipFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;

      if (file.path == null || file.path!.trim().isEmpty) {
        _showErrorSnackBar('Selected file is invalid');
        return;
      }

      setState(() {
        _attachedProofPath = file.path!;
        _attachedProofName = file.name;
      });

      _showSuccessSnackBar('Slip selected successfully');
    } catch (_) {
      _showErrorSnackBar('Unable to open file manager');
    }
  }

  void _removeSlip() {
    setState(() {
      _attachedProofPath = null;
      _attachedProofName = null;
    });

    _showSuccessSnackBar('Slip removed');
  }

  bool _isImageFile(String? path) {
    if (path == null || path.isEmpty) return false;
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  void _showSuccessSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final bank = Provider.of<PaymentProvider>(context).bankDetails;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'Shipping Details',
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Address',
                      hint: '123 Main Street, Apt 4B',
                      controller: _addressController,
                      prefixIcon: Icons.location_on_outlined,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Address is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'City',
                      hint: 'Bangkok',
                      controller: _cityController,
                      prefixIcon: Icons.location_city_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'City is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      hint: '+66 81 234 5678',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Phone is required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Payment Method',
                child: Column(
                  children: [
                    _PaymentOption(
                      icon: Icons.payments_outlined,
                      label: 'Cash on Delivery',
                      subtitle: 'Pay when your order arrives',
                      isSelected: _selectedPayment == PaymentMethod.cod,
                      onTap: () => setState(
                        () => _selectedPayment = PaymentMethod.cod,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PaymentOption(
                      icon: Icons.account_balance_outlined,
                      label: 'Bank Transfer',
                      subtitle: 'Pay via bank transfer / PromptPay',
                      isSelected:
                          _selectedPayment == PaymentMethod.bankTransfer,
                      onTap: () => setState(
                        () => _selectedPayment = PaymentMethod.bankTransfer,
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState:
                          _selectedPayment == PaymentMethod.bankTransfer
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                _BankInfoRow(
                                  icon: Icons.account_balance,
                                  label: 'Bank',
                                  value: bank.bankName,
                                ),
                                const Divider(height: 20),
                                _BankInfoRow(
                                  icon: Icons.numbers,
                                  label: 'Account No.',
                                  value: bank.accountNumber,
                                  copyable: true,
                                ),
                                const Divider(height: 20),
                                _BankInfoRow(
                                  icon: Icons.business,
                                  label: 'Account Name',
                                  value: bank.accountName,
                                ),
                                const Divider(height: 20),
                                _BankInfoRow(
                                  icon: Icons.qr_code,
                                  label: 'PromptPay',
                                  value: bank.promptPayId,
                                  copyable: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.textLightColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.qr_code_2,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Scan QR to Pay',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDarkColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                bank.qrCodeUrl != null &&
                                        bank.qrCodeUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          bank.qrCodeUrl!,
                                          height: 180,
                                          width: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _MockQrCode(
                                            promptPay: bank.promptPayId,
                                          ),
                                        ),
                                      )
                                    : _MockQrCode(
                                        promptPay: bank.promptPayId,
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ProofUploadTile(
                            attachedFileName: _attachedProofName,
                            onAttach: _showSlipSourcePicker,
                            onRemove: _removeSlip,
                          ),
                          if (_hasAttachedProof &&
                              _isImageFile(_attachedProofPath)) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      AppTheme.textLightColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Slip Preview',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDarkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_attachedProofPath!),
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        height: 120,
                                        color: AppTheme.backgroundColor,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Preview unavailable',
                                          style: TextStyle(
                                            color: AppTheme.textMediumColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Order Summary',
                child: Column(
                  children: [
                    ...cart.items.values.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} × ${item.quantity}',
                                style: const TextStyle(
                                  color: AppTheme.textMediumColor,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              CurrencyUtils.format(
                                item.product.price * item.quantity,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Shipping',
                          style: TextStyle(color: AppTheme.textMediumColor),
                        ),
                        Text(
                          'Free',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(cart.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Place Order',
                onPressed: _placeOrder,
                isLoading: _isPlacing,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.06)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.textLightColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textMediumColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textDarkColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMediumColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _BankInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const _BankInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 18),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppTheme.textMediumColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textDarkColor,
              fontSize: 13,
            ),
          ),
        ),
        if (copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(
              Icons.copy,
              size: 16,
              color: AppTheme.textMediumColor,
            ),
          ),
      ],
    );
  }
}

class _MockQrCode extends StatelessWidget {
  final String promptPay;

  const _MockQrCode({required this.promptPay});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180, maxHeight: 180),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppTheme.textLightColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxWidth.clamp(0.0, 130.0);
                    return CustomPaint(
                      size: Size(side, side),
                      painter: _QrPainter(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PromptPay: $promptPay',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMediumColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textDarkColor
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 12;

    final pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1],
      [1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1],
      [1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0],
      [1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0],
      [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1],
      [0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1],
      [1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1],
    ];

    for (int row = 0; row < pattern.length; row++) {
      for (int col = 0; col < pattern[row].length; col++) {
        if (pattern[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize - 1,
              cellSize - 1,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProofUploadTile extends StatelessWidget {
  final String? attachedFileName;
  final VoidCallback onAttach;
  final VoidCallback onRemove;

  const _ProofUploadTile({
    required this.attachedFileName,
    required this.onAttach,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile =
        attachedFileName != null && attachedFileName!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasFile
            ? AppTheme.successColor.withValues(alpha: 0.06)
            : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFile
              ? AppTheme.successColor.withValues(alpha: 0.4)
              : AppTheme.textLightColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasFile
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFile
                  ? Icons.check_circle_outline
                  : Icons.upload_file_outlined,
              color: hasFile
                  ? AppTheme.successColor
                  : AppTheme.textMediumColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Proof of Transfer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  hasFile
                      ? attachedFileName!
                      : 'Upload your transfer slip (JPG/PNG/PDF)',
                  style: TextStyle(
                    color: hasFile
                        ? AppTheme.successColor
                        : AppTheme.textMediumColor,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          hasFile
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onAttach,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Replace',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.close,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: onAttach,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}