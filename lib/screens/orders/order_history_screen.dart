import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../services/providers/order_provider.dart';
import '../../widgets/order_tile.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final Set<String> _processingOrderIds = {};

  bool _isProcessing(String orderId) => _processingOrderIds.contains(orderId);

  Future<void> _showSlipSourcePicker(OrderModel order) async {
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
                  'Manage Payment Slip',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
                if (order.proofOfTransferPath != null &&
                    order.proofOfTransferPath!.trim().isNotEmpty)
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
        await _pickSlipFromGallery(order);
        break;
      case 'files':
        await _pickSlipFromFiles(order);
        break;
      case 'remove':
        await _removeSlip(order);
        break;
    }
  }

  Future<void> _pickSlipFromGallery(OrderModel order) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) return;

      await _attachSlip(order, picked.path);
    } catch (_) {
      _showErrorSnackBar('Unable to open gallery');
    }
  }

  Future<void> _pickSlipFromFiles(OrderModel order) async {
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

      await _attachSlip(order, file.path!);
    } catch (_) {
      _showErrorSnackBar('Unable to open file manager');
    }
  }

  Future<void> _attachSlip(OrderModel order, String filePath) async {
    if (_isProcessing(order.id)) return;

    setState(() {
      _processingOrderIds.add(order.id);
    });

    try {
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).attachProofOfTransfer(order.id, filePath);

      if (!mounted) return;

      final hasOldSlip =
          order.proofOfTransferPath != null &&
          order.proofOfTransferPath!.trim().isNotEmpty;

      _showSuccessSnackBar(
        hasOldSlip
            ? 'Slip re-uploaded successfully'
            : 'Slip uploaded successfully',
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Slip upload failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processingOrderIds.remove(order.id);
        });
      }
    }
  }

  Future<void> _removeSlip(OrderModel order) async {
    if (_isProcessing(order.id)) return;

    setState(() {
      _processingOrderIds.add(order.id);
    });

    try {
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).removeProofOfTransfer(order.id);

      if (!mounted) return;
      _showSuccessSnackBar('Slip removed successfully');
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Unable to remove slip: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processingOrderIds.remove(order.id);
        });
      }
    }
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

  bool _canManageSlip(OrderModel order) {
    return order.paymentMethod == PaymentMethod.bankTransfer &&
        order.paymentStatus != 'Verified';
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: AppTheme.textLightColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your completed orders will appear here.',
                    style: TextStyle(color: AppTheme.textMediumColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (ctx, i) {
                final order = orders[i];
                final canManage = _canManageSlip(order);
                final hasSlip =
                    order.proofOfTransferPath != null &&
                    order.proofOfTransferPath!.trim().isNotEmpty;
                final isProcessing = _isProcessing(order.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: [
                      OrderTile(
                        key: ValueKey<String>('shopease.orderTile.${order.id}'),
                        order: order,
                      ),
                      if (canManage)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                            border: Border.all(
                              color: AppTheme.textLightColor.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                height: 20,
                                color: AppTheme.textLightColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    hasSlip
                                        ? Icons.check_circle_outline
                                        : Icons.upload_file_outlined,
                                    size: 18,
                                    color: hasSlip
                                        ? AppTheme.successColor
                                        : AppTheme.textMediumColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      hasSlip
                                          ? 'Slip added. You can edit or remove it.'
                                          : 'No slip uploaded yet.',
                                      style: TextStyle(
                                        color: hasSlip
                                            ? AppTheme.successColor
                                            : AppTheme.textMediumColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: isProcessing
                                          ? null
                                          : () => _showSlipSourcePicker(order),
                                      icon: isProcessing
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              hasSlip
                                                  ? Icons.refresh
                                                  : Icons.upload_file,
                                              size: 18,
                                            ),
                                      label: Text(
                                        isProcessing
                                            ? 'Processing...'
                                            : hasSlip
                                            ? 'Edit Slip'
                                            : 'Upload Slip',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        disabledBackgroundColor: AppTheme
                                            .primaryColor
                                            .withValues(alpha: 0.7),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (hasSlip) ...[
                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: isProcessing
                                          ? null
                                          : () => _removeSlip(order),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.errorColor,
                                        side: const BorderSide(
                                          color: AppTheme.errorColor,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
