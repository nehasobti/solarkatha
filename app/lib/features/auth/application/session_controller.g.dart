// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves the signed-in user into an [AppSession] and rebuilds whenever the
/// Supabase user changes (sign-in, sign-out).
///
/// Offline-first: once a user has synced, their profile and company are read
/// from the device, so the app opens on a rooftop with no signal. The network
/// is only needed on the very first login (to claim an invite).

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Resolves the signed-in user into an [AppSession] and rebuilds whenever the
/// Supabase user changes (sign-in, sign-out).
///
/// Offline-first: once a user has synced, their profile and company are read
/// from the device, so the app opens on a rooftop with no signal. The network
/// is only needed on the very first login (to claim an invite).
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, AppSession> {
  /// Resolves the signed-in user into an [AppSession] and rebuilds whenever the
  /// Supabase user changes (sign-in, sign-out).
  ///
  /// Offline-first: once a user has synced, their profile and company are read
  /// from the device, so the app opens on a rooftop with no signal. The network
  /// is only needed on the very first login (to claim an invite).
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'6079a2c2bcf3c4c24b191d27df527870eaad07e9';

/// Resolves the signed-in user into an [AppSession] and rebuilds whenever the
/// Supabase user changes (sign-in, sign-out).
///
/// Offline-first: once a user has synced, their profile and company are read
/// from the device, so the app opens on a rooftop with no signal. The network
/// is only needed on the very first login (to claim an invite).

abstract class _$SessionController extends $AsyncNotifier<AppSession> {
  FutureOr<AppSession> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppSession>, AppSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSession>, AppSession>,
              AsyncValue<AppSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
