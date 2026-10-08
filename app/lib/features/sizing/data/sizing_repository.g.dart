// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sizing_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sizingConfig)
final sizingConfigProvider = SizingConfigProvider._();

final class SizingConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<SizingConfig?>,
          SizingConfig?,
          Stream<SizingConfig?>
        >
    with $FutureModifier<SizingConfig?>, $StreamProvider<SizingConfig?> {
  SizingConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sizingConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sizingConfigHash();

  @$internal
  @override
  $StreamProviderElement<SizingConfig?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SizingConfig?> create(Ref ref) {
    return sizingConfig(ref);
  }
}

String _$sizingConfigHash() => r'5e8103b8c896077d9fefc31b58c9ef6b771019a1';

@ProviderFor(generationService)
final generationServiceProvider = GenerationServiceProvider._();

final class GenerationServiceProvider
    extends
        $FunctionalProvider<
          GenerationService,
          GenerationService,
          GenerationService
        >
    with $Provider<GenerationService> {
  GenerationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generationServiceHash();

  @$internal
  @override
  $ProviderElement<GenerationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GenerationService create(Ref ref) {
    return generationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenerationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenerationService>(value),
    );
  }
}

String _$generationServiceHash() => r'41283816d36ce2bbadf9b2c498bbb01449dc6c69';
