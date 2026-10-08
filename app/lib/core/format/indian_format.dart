import 'package:intl/intl.dart';

/// Indian number formatting (lakh/crore grouping), e.g. ₹1,23,456.
abstract final class IndianFormat {
  static String _locale(String languageCode) =>
      languageCode == 'hi' ? 'hi_IN' : 'en_IN';

  static String rupees(num amount, {String languageCode = 'en'}) =>
      NumberFormat.currency(
        locale: _locale(languageCode),
        symbol: '₹',
        decimalDigits: 0,
      ).format(amount);

  static String number(num value, {String languageCode = 'en'}) =>
      NumberFormat.decimalPattern(_locale(languageCode)).format(value);

  static String kw(num value, {String languageCode = 'en'}) =>
      '${NumberFormat('#,##,##0.##', _locale(languageCode)).format(value)} kW';
}
