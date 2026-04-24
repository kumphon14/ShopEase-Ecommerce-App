// lib/services/providers/payment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bank_details.dart';

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  BankDetails _bankDetails = BankDetails();

  BankDetails get bankDetails => _bankDetails;

  PaymentProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _listenToBankDetails();
  }

  void _listenToBankDetails() {
    _firestore.collection('settings').doc('company_info').snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        _bankDetails = BankDetails(
          bankName: data['bankName'] ?? 'Kasikorn Bank (KBank)',
          accountNumber: data['accountNumber'] ?? '1234567890',
          accountName: data['accountName'] ?? 'ShopEase Co., Ltd.',
          promptPayId: data['promptPayId'] ?? '0812345678',
          qrCodeUrl: data['qrCodeUrl'],
        );
        notifyListeners();
      }
    });
  }

  /// Admin: update bank details
  Future<void> updateBankDetails({
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? promptPayId,
    String? qrCodeUrl,
  }) async {
    final updated = _bankDetails.copyWith(
      bankName: bankName,
      accountNumber: accountNumber,
      accountName: accountName,
      promptPayId: promptPayId,
      qrCodeUrl: qrCodeUrl,
    );

    await _firestore.collection('settings').doc('company_info').set({
      'bankName': updated.bankName,
      'accountNumber': updated.accountNumber,
      'accountName': updated.accountName,
      'promptPayId': updated.promptPayId,
      'qrCodeUrl': updated.qrCodeUrl,
    }, SetOptions(merge: true));
  }

  /// Admin: update QR code URL/path
  Future<void> updateQrCode(String url) async {
    await _firestore.collection('settings').doc('company_info').set({
      'qrCodeUrl': url,
    }, SetOptions(merge: true));
  }

  /// Admin: reset bank details to defaults
  Future<void> resetBankDetails() async {
    final defaultDetails = BankDetails();
    await _firestore.collection('settings').doc('company_info').set({
      'bankName': defaultDetails.bankName,
      'accountNumber': defaultDetails.accountNumber,
      'accountName': defaultDetails.accountName,
      'promptPayId': defaultDetails.promptPayId,
      'qrCodeUrl': null,
    }, SetOptions(merge: true));
  }
}
