import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_providers.dart';

part 'auth_repository.g.dart';

/// Sign-in through Supabase Auth. The app uses mobile + password; accounts
/// are created by the administrator (sign-ups are off).
class AuthRepository {
  AuthRepository(this._auth);

  final GoTrueClient _auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// [phone] in E.164 form, e.g. `+919412000000`.
  Future<void> signInWithPassword({
    required String phone,
    required String password,
  }) => _auth.signInWithPassword(phone: phone, password: password);

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
