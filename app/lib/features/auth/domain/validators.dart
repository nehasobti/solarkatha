/// Returns the E.164 form (`+91XXXXXXXXXX`) of an Indian mobile number, or
/// null if [input] is not one. Accepts spaces, dashes, a leading 0, 91 or +91.
String? normalizeIndianMobile(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) {
    digits = digits.substring(2);
  } else if (digits.length == 11 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) return null;
  return '+91$digits';
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Returns the trimmed, lower-cased email, or null if it is not valid.
String? normalizeEmail(String input) {
  final email = input.trim().toLowerCase();
  return _emailPattern.hasMatch(email) ? email : null;
}

bool isValidOtp(String input) => RegExp(r'^\d{6}$').hasMatch(input.trim());
