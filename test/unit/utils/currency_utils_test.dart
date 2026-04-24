// test/unit/utils/currency_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_ecommerce_app/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils', () {
    group('format', () {
      test('formats 0.0 as ฿0.00', () {
        expect(CurrencyUtils.format(0.0), equals('฿0.00'));
      });

      test('formats 10.0 as ฿10.00', () {
        expect(CurrencyUtils.format(10.0), equals('฿10.00'));
      });

      test('formats 1499.50 with comma separator as ฿1,499.50', () {
        expect(CurrencyUtils.format(1499.50), equals('฿1,499.50'));
      });

      test('formats 899.99 as ฿899.99', () {
        expect(CurrencyUtils.format(899.99), equals('฿899.99'));
      });

      test('formats 100000.00 with comma separators as ฿100,000.00', () {
        expect(CurrencyUtils.format(100000.00), equals('฿100,000.00'));
      });

      test('result always contains the ฿ symbol as prefix', () {
        final result = CurrencyUtils.format(250.0);
        expect(result.startsWith('฿'), isTrue);
      });

      test('result always contains exactly 2 decimal places', () {
        final result = CurrencyUtils.format(50.0);
        // Check there is a dot followed by exactly 2 digits at end
        expect(result, contains('.'));
        final decimalPart = result.split('.').last;
        expect(decimalPart.length, equals(2));
      });

      group('edge cases', () {
        test('rounds 0.001 down to ฿0.00 (2 decimal places)', () {
          expect(CurrencyUtils.format(0.001), equals('฿0.00'));
        });

        test('rounds 1.999 to ฿2.00 (2 decimal rounding)', () {
          expect(CurrencyUtils.format(1.999), equals('฿2.00'));
        });

        test('formats negative number consistently (documents actual behavior)', () {
          // NumberFormat with en_US locale renders negatives as -฿50.00
          final result = CurrencyUtils.format(-50.0);
          // Assert it contains the symbol and the number — exact format depends on intl locale
          expect(result, contains('฿'));
          expect(result, contains('50'));
        });
      });
    });
  });
}
