import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solarkatha/core/router/redirect.dart';
import 'package:solarkatha/core/router/routes.dart';
import 'package:solarkatha/data/models/user_role.dart';
import 'package:solarkatha/features/auth/application/app_session.dart';

import '../../helpers/fakes.dart';

String? redirect(AsyncValue<AppSession> session, String location) =>
    resolveRedirect(session: session, uri: Uri.parse(location));

void main() {
  group('while loading', () {
    const loading = AsyncLoading<AppSession>();

    test('sends to splash and remembers the target', () {
      expect(redirect(loading, '/leads'), '/splash?from=%2Fleads');
    });

    test('does not remember auth-flow pages', () {
      expect(redirect(loading, '/login'), Routes.splash);
      expect(redirect(loading, '/'), Routes.splash);
    });

    test('stays on splash', () {
      expect(redirect(loading, Routes.splash), isNull);
    });

    test('public tracking page never redirects', () {
      expect(redirect(loading, '/t/abc123'), isNull);
    });
  });

  test('error goes to splash (which offers retry)', () {
    final error = AsyncError<AppSession>(Exception('x'), StackTrace.empty);
    expect(redirect(error, '/home'), '/splash?from=%2Fhome');
  });

  group('signed out', () {
    const s = AsyncData<AppSession>(SignedOut());

    test('any private page goes to login', () {
      expect(redirect(s, '/dashboard'), Routes.login);
      expect(redirect(s, '/'), Routes.login);
    });

    test('login stays', () => expect(redirect(s, Routes.login), isNull));

    test('tracking page stays', () => expect(redirect(s, '/t/tok'), isNull));
  });

  test('needs company goes to onboarding', () {
    const s = AsyncData<AppSession>(NeedsCompany(userId: 'u'));
    expect(redirect(s, '/home'), Routes.onboarding);
    expect(redirect(s, Routes.onboarding), isNull);
  });

  test('deactivated goes to deactivated', () {
    const s = AsyncData<AppSession>(Deactivated());
    expect(redirect(s, '/leads'), Routes.deactivated);
  });

  group('ready', () {
    final owner = AsyncData<AppSession>(readyAs(UserRole.owner));
    final sales = AsyncData<AppSession>(readyAs(UserRole.sales));
    final installer = AsyncData<AppSession>(readyAs(UserRole.installer));

    test('lands on the role home', () {
      expect(redirect(owner, Routes.login), Routes.dashboard);
      expect(redirect(sales, Routes.login), Routes.home);
      expect(redirect(installer, '/'), Routes.projects);
    });

    test('returns to the remembered page when allowed', () {
      expect(redirect(owner, '/splash?from=%2Fteam'), '/team');
      expect(redirect(sales, '/splash?from=%2Fteam'), Routes.home);
    });

    test('role guards', () {
      expect(redirect(owner, '/team'), isNull);
      expect(redirect(sales, '/leads'), isNull);
      expect(redirect(sales, '/dashboard'), Routes.home);
      expect(redirect(sales, '/config'), Routes.home);
      expect(redirect(installer, '/leads'), Routes.projects);
      expect(redirect(installer, '/settings'), isNull);
    });
  });

  group('web landing page', () {
    String? web(AsyncValue<AppSession> session, String location) =>
        resolveRedirect(session: session, uri: Uri.parse(location), web: true);

    test('is public on the web whatever the session', () {
      expect(web(const AsyncLoading(), '/'), isNull);
      expect(web(const AsyncData(SignedOut()), '/'), isNull);
    });

    test('the Android app still sends / to login', () {
      expect(redirect(const AsyncData(SignedOut()), '/'), Routes.login);
    });
  });
}
