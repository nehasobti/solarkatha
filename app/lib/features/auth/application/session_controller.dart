import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

import '../../../data/models/company.dart';
import '../../../data/models/profile.dart';
import '../../../data/powersync/powersync_providers.dart';
import '../../../data/push/push_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'app_session.dart';

part 'session_controller.g.dart';

/// Resolves the signed-in user into an [AppSession] and rebuilds whenever the
/// Supabase user changes (sign-in, sign-out).
///
/// Offline-first: once a user has synced, their profile and company are read
/// from the device, so the app opens on a rooftop with no signal. The network
/// is only needed on the very first login (to claim an invite).
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<AppSession> build() async {
    final auth = ref.watch(authRepositoryProvider);
    final profiles = ref.watch(profileRepositoryProvider);

    final user = auth.currentUser;
    final sub = auth.authStateChanges.listen((event) {
      final changed = event.session?.user.id != user?.id;
      if (changed || event.event == AuthChangeEvent.signedOut) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(sub.cancel);

    if (user == null) return const SignedOut();

    final local = await _readLocal(user.id);
    if (local != null) return local;

    var profile = await profiles.fetchProfile(user.id);
    if (profile == null && await profiles.claimInvite()) {
      profile = await profiles.fetchProfile(user.id);
    }
    if (profile == null) {
      return NeedsCompany(
        userId: user.id,
        phone: user.phone,
        email: user.email,
      );
    }
    if (!profile.active) return const Deactivated();

    final company = await profiles.fetchCompany(profile.companyId);
    return Ready(profile: profile, company: company);
  }

  Future<AppSession?> _readLocal(String userId) async {
    final db = ref.read(powerSyncDbProvider);
    final p = await db.getOptional('SELECT * FROM profiles WHERE id = ?', [
      userId,
    ]);
    if (p == null) return null;
    final profile = Profile.fromJson({
      ...p,
      'name': p['name'] ?? '',
      'language': p['language'] ?? 'en',
      'active': p['active'] == 1,
    });
    if (!profile.active) return const Deactivated();
    final c = await db.getOptional('SELECT * FROM companies WHERE id = ?', [
      profile.companyId,
    ]);
    if (c == null) return null;
    return Ready(profile: profile, company: Company.fromJson(c));
  }

  /// Re-reads the profile and company, e.g. after creating a company.
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> signOut() async {
    // While still signed in, so RLS lets us drop this phone's push token.
    await ref.read(pushServiceProvider).stop();
    await ref.read(authRepositoryProvider).signOut();
  }
}
