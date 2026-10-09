// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Satellite tiles on/off (widget tests turn them off: no network).

@ProviderFor(satelliteTiles)
final satelliteTilesProvider = SatelliteTilesProvider._();

/// Satellite tiles on/off (widget tests turn them off: no network).

final class SatelliteTilesProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Satellite tiles on/off (widget tests turn them off: no network).
  SatelliteTilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'satelliteTilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$satelliteTilesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return satelliteTiles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$satelliteTilesHash() => r'0ee8aabf69ed2b219901baae8fb0c99b5c7b7547';
