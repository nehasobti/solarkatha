import 'package:flutter_test/flutter_test.dart';
import 'package:solarkatha/core/format/indian_format.dart';

void main() {
  test('rupees use lakh grouping', () {
    expect(IndianFormat.rupees(123456), '₹1,23,456');
    expect(IndianFormat.rupees(12345678), '₹1,23,45,678');
    expect(IndianFormat.rupees(0), '₹0');
  });

  test('rupees in Hindi keep lakh grouping', () {
    expect(IndianFormat.rupees(123456, languageCode: 'hi'), '₹1,23,456');
  });

  test('numbers and kW', () {
    expect(IndianFormat.number(1500000), '15,00,000');
    expect(IndianFormat.kw(3), '3 kW');
    expect(IndianFormat.kw(2.5), '2.5 kW');
  });
}
