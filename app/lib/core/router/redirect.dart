import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/app_session.dart';
import 'routes.dart';

/// Decides where to send the user for [uri] given the current [session].
/// Returns null to stay on [uri].
String? resolveRedirect({
  required AsyncValue<AppSession> session,
  required Uri uri,
}) {
  final path = uri.path;
  if (Routes.isPublic(path)) return null;

  final current = session.value;

  // Still resolving (first load) or failed: the splash screen shows progress
  // or the error with a retry button. Remember where the user was going.
  if (current == null || session.hasError && !session.isLoading) {
    if (path == Routes.splash) return null;
    final from = Routes.isAuthFlow(path) || path == '/' ? null : uri.toString();
    return Uri(
      path: Routes.splash,
      queryParameters: from == null ? null : {'from': from},
    ).toString();
  }

  switch (current) {
    case SignedOut():
      return path == Routes.login ? null : Routes.login;
    case NeedsCompany():
      return path == Routes.onboarding ? null : Routes.onboarding;
    case Deactivated():
      return path == Routes.deactivated ? null : Routes.deactivated;
    case Ready(:final profile):
      final role = profile.role;
      if (Routes.isAuthFlow(path) || path == '/') {
        final from = uri.queryParameters['from'];
        if (from != null) {
          final target = Uri.tryParse(from);
          if (target != null &&
              !Routes.isAuthFlow(target.path) &&
              Routes.isAllowed(role, target.path)) {
            return from;
          }
        }
        return Routes.homeFor(role);
      }
      return Routes.isAllowed(role, path) ? null : Routes.homeFor(role);
  }
}
