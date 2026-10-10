import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/firebase_options.dart';
import '../supabase/supabase_providers.dart';

part 'push_service.g.dart';

final _log = Logger('PushService');

/// Phone notifications (FCM, Android only). Registers this phone's token for
/// the signed-in member and reports taps so the app can open the project.
class PushService {
  PushService(this._client);

  final SupabaseClient _client;
  final _subs = <StreamSubscription<Object?>>[];
  String? _profileId;

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Starts Firebase once, before runApp. Never throws.
  static Future<void> init() async {
    if (!supported) return;
    try {
      await Firebase.initializeApp(options: androidFirebaseOptions);
    } catch (e) {
      _log.warning('Firebase init failed: $e');
    }
  }

  /// Saves the token for [profileId] and listens for taps. [onOpen] gets
  /// the in-app route carried by the notification.
  Future<void> start({
    required String profileId,
    required void Function(String route) onOpen,
  }) async {
    if (!supported || Firebase.apps.isEmpty || _profileId == profileId) return;
    await stop();
    _profileId = profileId;
    try {
      final fcm = FirebaseMessaging.instance;
      final perm = await fcm.requestPermission();
      if (perm.authorizationStatus == AuthorizationStatus.denied) return;

      Future<void> save(String token) => _client.rpc(
        'register_device_token',
        params: {'p_token': token, 'p_platform': 'android'},
      );

      final token = await fcm.getToken();
      if (token != null) await save(token);
      _subs
        ..add(fcm.onTokenRefresh.listen((t) => save(t).ignore()))
        ..add(
          FirebaseMessaging.onMessageOpenedApp.listen((m) {
            final route = m.data['route'];
            if (route is String) onOpen(route);
          }),
        );
      final initial = await fcm.getInitialMessage();
      final route = initial?.data['route'];
      if (route is String) onOpen(route);
    } catch (e) {
      // Offline or Play services missing: the in-app bell still works.
      _log.warning('Push registration failed: $e');
    }
  }

  /// Before sign-out: stop listening and forget this phone's token.
  Future<void> stop() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    if (_profileId == null || !supported || Firebase.apps.isEmpty) return;
    _profileId = null;
    try {
      final token = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 3),
      );
      if (token != null) {
        await _client
            .rpc('unregister_device_token', params: {'p_token': token})
            .timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      _log.warning('Push unregister failed: $e');
    }
  }
}

@Riverpod(keepAlive: true)
PushService pushService(Ref ref) =>
    PushService(ref.watch(supabaseClientProvider));
