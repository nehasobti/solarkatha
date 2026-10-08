// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'powersync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localData)
final localDataProvider = LocalDataProvider._();

final class LocalDataProvider
    extends $FunctionalProvider<LocalData, LocalData, LocalData>
    with $Provider<LocalData> {
  LocalDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDataHash();

  @$internal
  @override
  $ProviderElement<LocalData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalData create(Ref ref) {
    return localData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalData>(value),
    );
  }
}

String _$localDataHash() => r'c3d4bcfeb802b191e778f1d4bc41cb355ed818f7';

@ProviderFor(powerSyncDb)
final powerSyncDbProvider = PowerSyncDbProvider._();

final class PowerSyncDbProvider
    extends
        $FunctionalProvider<
          PowerSyncDatabase,
          PowerSyncDatabase,
          PowerSyncDatabase
        >
    with $Provider<PowerSyncDatabase> {
  PowerSyncDbProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'powerSyncDbProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$powerSyncDbHash();

  @$internal
  @override
  $ProviderElement<PowerSyncDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PowerSyncDatabase create(Ref ref) {
    return powerSyncDb(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PowerSyncDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PowerSyncDatabase>(value),
    );
  }
}

String _$powerSyncDbHash() => r'9dd762a5def50de03ff5918d776a5ffc30472ee7';

@ProviderFor(photoQueue)
final photoQueueProvider = PhotoQueueProvider._();

final class PhotoQueueProvider
    extends
        $FunctionalProvider<AttachmentQueue, AttachmentQueue, AttachmentQueue>
    with $Provider<AttachmentQueue> {
  PhotoQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoQueueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoQueueHash();

  @$internal
  @override
  $ProviderElement<AttachmentQueue> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AttachmentQueue create(Ref ref) {
    return photoQueue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttachmentQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttachmentQueue>(value),
    );
  }
}

String _$photoQueueHash() => r'8b89bbf0aef65a5c7f163691b3a05d80d1a4b491';

/// Connects sync and the photo queue while someone is signed in; clears the
/// device when they sign out.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Connects sync and the photo queue while someone is signed in; clears the
/// device when they sign out.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, void> {
  /// Connects sync and the photo queue while someone is signed in; clears the
  /// device when they sign out.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$syncControllerHash() => r'06109b934ee2d886c2cc937e3bad337899bddada';

/// Connects sync and the photo queue while someone is signed in; clears the
/// device when they sign out.

abstract class _$SyncController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Live sync status for the offline banner and settings.

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

/// Live sync status for the offline banner and settings.

final class SyncStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncStatus>,
          SyncStatus,
          Stream<SyncStatus>
        >
    with $FutureModifier<SyncStatus>, $StreamProvider<SyncStatus> {
  /// Live sync status for the offline banner and settings.
  SyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $StreamProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SyncStatus> create(Ref ref) {
    return syncStatus(ref);
  }
}

String _$syncStatusHash() => r'fce51c4670c14f4cf836a3e38e84340f6cb2cc49';
