import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_providers.dart';

part 'auth_repository.g.dart';

/// Phone OTP (all roles) and email OTP (owners) sign-in through Supabase Auth.
class AuthRepository {
  AuthRepository(this._auth);

  final GoTrueClient _auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// [phone] must be in E.164 form, e.g. `+919876543210`.
  Future<void> sendPhoneOtp(String phone) => _auth.signInWithOtp(phone: phone);

  Future<void> verifyPhoneOtp({required String phone, required String token}) =>
      _auth.verifyOTP(type: OtpType.sms, phone: phone, token: token);

  Future<void> sendEmailOtp(String email) =>
      _auth.signInWithOtp(email: email, shouldCreateUser: true);

  Future<void> verifyEmailOtp({required String email, required String token}) =>
      _auth.verifyOTP(type: OtpType.email, email: email, token: token);

  Future<void> signOut() => _auth.signOut();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider).auth);
