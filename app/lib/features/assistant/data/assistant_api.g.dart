// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assistantApi)
final assistantApiProvider = AssistantApiProvider._();

final class AssistantApiProvider
    extends $FunctionalProvider<AssistantApi, AssistantApi, AssistantApi>
    with $Provider<AssistantApi> {
  AssistantApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantApiHash();

  @$internal
  @override
  $ProviderElement<AssistantApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssistantApi create(Ref ref) {
    return assistantApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantApi>(value),
    );
  }
}

String _$assistantApiHash() => r'0822a86f6b4450885b89399b6cbd42a7771b9820';
