// test/unit/models/bank_details_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/models/bank_details.dart';

void main() {
  group('BankDetails', () {
    group('constructor defaults', () {
      test('bankName defaults to Kasikorn Bank (KBank)', () {
        expect(BankDetails().bankName, equals('Kasikorn Bank (KBank)'));
      });

      test('accountNumber defaults to 1234567890', () {
        expect(BankDetails().accountNumber, equals('1234567890'));
      });

      test('accountName defaults to ShopEase Co., Ltd.', () {
        expect(BankDetails().accountName, equals('ShopEase Co., Ltd.'));
      });

      test('promptPayId defaults to 0812345678', () {
        expect(BankDetails().promptPayId, equals('0812345678'));
      });

      test('qrCodeUrl defaults to null', () {
        expect(BankDetails().qrCodeUrl, isNull);
      });
    });

    group('copyWith', () {
      test('overrides bankName and preserves all other fields', () {
        final original = BankDetails();
        final updated = original.copyWith(bankName: 'SCB');

        expect(updated.bankName, equals('SCB'));
        expect(updated.accountNumber, equals(original.accountNumber));
        expect(updated.accountName, equals(original.accountName));
        expect(updated.promptPayId, equals(original.promptPayId));
        expect(updated.qrCodeUrl, equals(original.qrCodeUrl));
      });

      test('overrides accountNumber and promptPayId simultaneously, preserves other fields', () {
        final original = BankDetails();
        final updated = original.copyWith(
          accountNumber: '9999999999',
          promptPayId: '0900000000',
        );

        expect(updated.accountNumber, equals('9999999999'));
        expect(updated.promptPayId, equals('0900000000'));
        expect(updated.bankName, equals(original.bankName));
        expect(updated.accountName, equals(original.accountName));
        expect(updated.qrCodeUrl, isNull);
      });

      test('copyWith with no arguments returns logically equivalent instance', () {
        final original = BankDetails(
          bankName: 'Test Bank',
          accountNumber: '111',
          accountName: 'Test Account',
          promptPayId: '099',
          qrCodeUrl: 'https://example.com/qr.png',
        );
        final copy = original.copyWith();

        expect(copy.bankName, equals(original.bankName));
        expect(copy.accountNumber, equals(original.accountNumber));
        expect(copy.accountName, equals(original.accountName));
        expect(copy.promptPayId, equals(original.promptPayId));
        expect(copy.qrCodeUrl, equals(original.qrCodeUrl));
      });

      test('returns a new instance, not the same reference', () {
        final original = BankDetails();
        final copy = original.copyWith();

        expect(copy, isNot(same(original)));
      });

      test('copyWith with qrCodeUrl: null preserves existing non-null qrCodeUrl', () {
        // Because copyWith uses `qrCodeUrl ?? this.qrCodeUrl`, passing null
        // keeps the original value — it cannot unset qrCodeUrl via copyWith.
        final original = BankDetails(qrCodeUrl: 'https://example.com/qr.png');
        final updated = original.copyWith(qrCodeUrl: null);

        expect(updated.qrCodeUrl, equals('https://example.com/qr.png'));
      });

      test('overrides qrCodeUrl when a non-null value is provided', () {
        final original = BankDetails();
        final updated = original.copyWith(qrCodeUrl: 'https://example.com/new_qr.png');

        expect(updated.qrCodeUrl, equals('https://example.com/new_qr.png'));
      });

      test('overrides all fields at once', () {
        final original = BankDetails();
        final updated = original.copyWith(
          bankName: 'Bangkok Bank',
          accountNumber: '0000000001',
          accountName: 'New Co.',
          promptPayId: '0811111111',
          qrCodeUrl: 'https://x.com/qr.png',
        );

        expect(updated.bankName, equals('Bangkok Bank'));
        expect(updated.accountNumber, equals('0000000001'));
        expect(updated.accountName, equals('New Co.'));
        expect(updated.promptPayId, equals('0811111111'));
        expect(updated.qrCodeUrl, equals('https://x.com/qr.png'));
      });
    });
  });
}
