import 'package:flutter_test/flutter_test.dart';
import 'package:solarkatha/features/auth/domain/validators.dart';

void main() {
  group('normalizeIndianMobile', () {
    test('accepts common formats', () {
      expect(normalizeIndianMobile('9876543210'), '+919876543210');
      expect(normalizeIndianMobile('98765 43210'), '+919876543210');
      expect(normalizeIndianMobile('+91 98765-43210'), '+919876543210');
      expect(normalizeIndianMobile('919876543210'), '+919876543210');
      expect(normalizeIndianMobile('09876543210'), '+919876543210');
    });

    test('rejects invalid numbers', () {
      expect(normalizeIndianMobile(''), isNull);
      expect(normalizeIndianMobile('12345'), isNull);
      expect(normalizeIndianMobile('5876543210'), isNull);
      expect(normalizeIndianMobile('98765432101'), isNull);
    });
  });

  test('normalizeEmail', () {
    expect(normalizeEmail('  Owner@Example.COM '), 'owner@example.com');
    expect(normalizeEmail('nope'), isNull);
    expect(normalizeEmail('a@b'), isNull);
  });

  test('isValidOtp', () {
    expect(isValidOtp('123456'), isTrue);
    expect(isValidOtp('12345'), isFalse);
    expect(isValidOtp('12a456'), isFalse);
  });
}
