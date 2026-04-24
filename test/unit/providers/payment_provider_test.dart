// test/unit/providers/payment_provider_test.dart
//
// Tests PaymentProvider bank detail state using FakeFirebaseFirestore.
// _listenToBankDetails() is a stream subscription triggered from the constructor.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shopease_ecommerce_app/services/providers/payment_provider.dart';
import 'package:shopease_ecommerce_app/models/bank_details.dart';

const _settingsPath = 'settings';
const _docId = 'company_info';

Future<PaymentProvider> _makeProvider(
  FakeFirebaseFirestore firestore, {
  Map<String, dynamic>? initialData,
}) async {
  if (initialData != null) {
    await firestore.collection(_settingsPath).doc(_docId).set(initialData);
  }
  final provider = PaymentProvider(firestore: firestore);
  await Future.delayed(const Duration(milliseconds: 50));
  return provider;
}

void main() {
  group('PaymentProvider', () {
    group('bankDetails initial state', () {
      test('starts with BankDetails defaults when no Firestore document exists', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore);

        final defaults = BankDetails();
        expect(provider.bankDetails.bankName, equals(defaults.bankName));
        expect(provider.bankDetails.accountNumber, equals(defaults.accountNumber));
        expect(provider.bankDetails.accountName, equals(defaults.accountName));
        expect(provider.bankDetails.promptPayId, equals(defaults.promptPayId));
        expect(provider.bankDetails.qrCodeUrl, isNull);
      });

      test('loads bankDetails from Firestore document when it exists', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, initialData: {
          'bankName': 'Bangkok Bank',
          'accountNumber': '0000001234',
          'accountName': 'Test Co.',
          'promptPayId': '0899999999',
          'qrCodeUrl': 'https://example.com/qr.png',
        });

        expect(provider.bankDetails.bankName, equals('Bangkok Bank'));
        expect(provider.bankDetails.accountNumber, equals('0000001234'));
        expect(provider.bankDetails.accountName, equals('Test Co.'));
        expect(provider.bankDetails.promptPayId, equals('0899999999'));
        expect(provider.bankDetails.qrCodeUrl, equals('https://example.com/qr.png'));
      });
    });

    group('updateBankDetails', () {
      test('applies only the specified field changes and preserves others', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, initialData: {
          'bankName': 'Kasikorn Bank (KBank)',
          'accountNumber': '1234567890',
          'accountName': 'ShopEase Co., Ltd.',
          'promptPayId': '0812345678',
          'qrCodeUrl': null,
        });

        await provider.updateBankDetails(bankName: 'SCB');

        final snap = await fakeFirestore.collection(_settingsPath).doc(_docId).get();
        expect(snap.data()!['bankName'], equals('SCB'));
        // Other fields should be preserved (from copyWith)
        expect(snap.data()!['accountNumber'], equals('1234567890'));
      });

      test('persists all fields to Firestore after update', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore);

        await provider.updateBankDetails(
          bankName: 'SCB',
          accountNumber: '9999999999',
        );

        final snap = await fakeFirestore.collection(_settingsPath).doc(_docId).get();
        expect(snap.exists, isTrue);
        expect(snap.data()!['bankName'], equals('SCB'));
        expect(snap.data()!['accountNumber'], equals('9999999999'));
      });
    });

    group('updateQrCode', () {
      test('writes only the qrCodeUrl field to Firestore', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore);

        await provider.updateQrCode('https://example.com/new_qr.png');

        final snap = await fakeFirestore.collection(_settingsPath).doc(_docId).get();
        expect(snap.data()!['qrCodeUrl'], equals('https://example.com/new_qr.png'));
      });
    });

    group('resetBankDetails', () {
      test('writes BankDetails default values to Firestore', () async {
        final fakeFirestore = FakeFirebaseFirestore();
        final provider = await _makeProvider(fakeFirestore, initialData: {
          'bankName': 'Custom Bank',
          'accountNumber': '0000000000',
          'accountName': 'Custom Co.',
          'promptPayId': '0000000000',
          'qrCodeUrl': 'https://example.com/qr.png',
        });

        await provider.resetBankDetails();

        final snap = await fakeFirestore.collection(_settingsPath).doc(_docId).get();
        final defaults = BankDetails();
        expect(snap.data()!['bankName'], equals(defaults.bankName));
        expect(snap.data()!['accountNumber'], equals(defaults.accountNumber));
        expect(snap.data()!['accountName'], equals(defaults.accountName));
        expect(snap.data()!['promptPayId'], equals(defaults.promptPayId));
        expect(snap.data()!['qrCodeUrl'], isNull);
      });
    });
  });
}
