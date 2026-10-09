// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trackingApi)
final trackingApiProvider = TrackingApiProvider._();

final class TrackingApiProvider
    extends $FunctionalProvider<TrackingApi, TrackingApi, TrackingApi>
    with $Provider<TrackingApi> {
  TrackingApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingApiHash();

  @$internal
  @override
  $ProviderElement<TrackingApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrackingApi create(Ref ref) {
    return trackingApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingApi>(value),
    );
  }
}

String _$trackingApiHash() => r'd2f69a4638a014e62bfc7de10f61c2faa43bf898';
