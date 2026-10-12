import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solarkatha/features/auth/application/app_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
    when(
      () => auth.signInWithPassword(
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  testWidgets('signed-out user sees English mobile + password login', (
    tester,
  ) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.byKey(const Key('login.password')), findsOneWidget);
    // No demo shortcuts and no self sign-up options.
    expect(find.text('Try the demo'), findsNothing);
    expect(find.textContaining('email'), findsNothing);
  });

  testWidgets('signed-out user sees Hindi login', (tester) async {
    await pumpApp(
      tester,
      session: const SignedOut(),
      language: 'hi',
      auth: auth,
    );
    expect(find.text('साइन इन करें'), findsWidgets);
    expect(find.text('पासवर्ड'), findsOneWidget);
  });

  testWidgets('switching language on the login screen', (tester) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    await tester.tap(find.text('हिंदी'));
    await tester.pumpAndSettle();
    expect(find.text('पासवर्ड'), findsOneWidget);
  });

  testWidgets('invalid number or empty password signs nothing in', (
    tester,
  ) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    await tester.enterText(find.byKey(const Key('login.id')), '12345');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a valid 10-digit Indian mobile number'),
      findsOneWidget,
    );
    verifyNever(
      () => auth.signInWithPassword(
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('signs in with the mobile in E.164 and the password', (
    tester,
  ) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    await tester.enterText(find.byKey(const Key('login.id')), '94120 00000');
    await tester.enterText(find.byKey(const Key('login.password')), 'secret');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
    verify(
      () => auth.signInWithPassword(
        phone: '+919412000000',
        password: 'secret',
      ),
    ).called(1);
  });

  testWidgets('wrong password shows a clear message', (tester) async {
    when(
      () => auth.signInWithPassword(
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      ),
    );
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    await tester.enterText(find.byKey(const Key('login.id')), '9412000000');
    await tester.enterText(find.byKey(const Key('login.password')), 'nope');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
    expect(find.text('Wrong mobile number or password.'), findsOneWidget);
  });

  testWidgets('web landing shows the pitch next to the login', (tester) async {
    await pumpApp(
      tester,
      session: const SignedOut(),
      auth: auth,
      size: const Size(1280, 900),
    );
    expect(find.textContaining('Sell rooftop solar faster'), findsOneWidget);
  });
}
