import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_role.dart';
import '../../l10n/gen/app_localizations.dart';

export '../../l10n/gen/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension UserRoleL10n on UserRole {
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.owner => l10n.roleOwner,
    UserRole.sales => l10n.roleSales,
    UserRole.installer => l10n.roleInstaller,
  };
}

/// Turns an exception into a short, translated message for the user.
String describeError(AppLocalizations l10n, Object error) {
  if (error is AuthException) {
    final code = error.code ?? '';
    if (code == 'invalid_credentials' ||
        error.message.toLowerCase().contains('invalid login')) {
      return l10n.wrongCredentials;
    }
    if (code == 'otp_expired' || code.contains('otp')) return l10n.otpIncorrect;
  }
  if (error is AuthRetryableFetchException) return l10n.errorNetwork;
  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('ClientException')) {
    return l10n.errorNetwork;
  }
  return l10n.errorGeneric;
}
