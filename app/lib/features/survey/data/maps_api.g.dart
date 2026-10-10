// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maps_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mapsApi)
final mapsApiProvider = MapsApiProvider._();

final class MapsApiProvider
    extends $FunctionalProvider<MapsApi, MapsApi, MapsApi>
    with $Provider<MapsApi> {
  MapsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapsApiHash();

  @$internal
  @override
  $ProviderElement<MapsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapsApi create(Ref ref) {
    return mapsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapsApi>(value),
    );
  }
}

String _$mapsApiHash() => r'6493b2a4936c28ae473f193f8eaecf62d925f665';
