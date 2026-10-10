// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_tiles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(googleTiles)
final googleTilesProvider = GoogleTilesProvider._();

final class GoogleTilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoogleTiles?>,
          GoogleTiles?,
          FutureOr<GoogleTiles?>
        >
    with $FutureModifier<GoogleTiles?>, $FutureProvider<GoogleTiles?> {
  GoogleTilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleTilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleTilesHash();

  @$internal
  @override
  $FutureProviderElement<GoogleTiles?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GoogleTiles?> create(Ref ref) {
    return googleTiles(ref);
  }
}

String _$googleTilesHash() => r'a86d1133a48de6d00480b5f5c69f3890dfd8ff52';
