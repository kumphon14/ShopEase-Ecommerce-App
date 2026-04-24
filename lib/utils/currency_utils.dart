import 'package:intl/intl.dart';

class CurrencyUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '฿',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }
}
