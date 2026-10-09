import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solarkatha/features/auth/application/app_session.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
    when(() => auth.sendPhoneOtp(any())).thenAnswer((_) async {});
    when(
      () => auth.verifyPhoneOtp(
        phone: any(named: 'phone'),
        token: any(named: 'token'),
      ),
    ).thenAnswer((_) async {});
  });

  testWidgets('signed-out user sees English login', (tester) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Send code'), findsOneWidget);
  });

  testWidgets('signed-out user sees Hindi login', (tester) async {
    await pumpApp(
      tester,
      session: const SignedOut(),
      language: 'hi',
      auth: auth,
    );
    expect(find.text('साइन इन करें'), findsOneWidget);
    expect(find.text('कोड भेजें'), findsOneWidget);
  });

  testWidgets('switching language on the login screen', (tester) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    await tester.tap(find.text('हिंदी'));
    await tester.pumpAndSettle();
    expect(find.text('कोड भेजें'), findsOneWidget);
  });

  testWidgets('invalid number shows an error and sends nothing', (
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
    verifyNever(() => auth.sendPhoneOtp(any()));
  });

  testWidgets('phone OTP flow sends and verifies in E.164', (tester) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    await tester.enterText(find.byKey(const Key('login.id')), '99999 00002');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
    verify(() => auth.sendPhoneOtp('+919999900002')).called(1);
    expect(find.text('Code sent to +919999900002'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login.otp')), '123456');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();
    verify(() => auth.verifyPhoneOtp(phone: '+919999900002', token: '123456'))
        .called(1);
  });

  testWidgets('demo button signs in as the owner test number', (tester) async {
    await pumpApp(tester, session: const SignedOut(), auth: auth);
    await tester.ensureVisible(find.byKey(const Key('login.demo.owner')));
    await tester.tap(find.byKey(const Key('login.demo.owner')));
    await tester.pumpAndSettle();
    verify(() => auth.sendPhoneOtp('+919999900001')).called(1);
    verify(() => auth.verifyPhoneOtp(phone: '+919999900001', token: '123456'))
        .called(1);
  });

  testWidgets('web landing shows the pitch next to the login', (tester) async {
    await pumpApp(
      tester,
      session: const SignedOut(),
      auth: auth,
      size: const Size(1280, 900),
    );
    expect(find.textContaining('Sell rooftop solar faster'), findsOneWidget);
    expect(find.text('Try the demo'), findsOneWidget);
  });
}
