// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_processor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs queued bill scans once the phone is online and the bill photo has
/// uploaded. Retries network/server failures; gives up on rejected requests
/// so the rep can enter the values by hand.

@ProviderFor(ScanProcessor)
final scanProcessorProvider = ScanProcessorProvider._();

/// Runs queued bill scans once the phone is online and the bill photo has
/// uploaded. Retries network/server failures; gives up on rejected requests
/// so the rep can enter the values by hand.
final class ScanProcessorProvider
    extends $NotifierProvider<ScanProcessor, void> {
  /// Runs queued bill scans once the phone is online and the bill photo has
  /// uploaded. Retries network/server failures; gives up on rejected requests
  /// so the rep can enter the values by hand.
  ScanProcessorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scanProcessorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scanProcessorHash();

  @$internal
  @override
  ScanProcessor create() => ScanProcessor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$scanProcessorHash() => r'35c984857655167cb8a1d925cc7c2c36e6117fc5';

/// Runs queued bill scans once the phone is online and the bill photo has
/// uploaded. Retries network/server failures; gives up on rejected requests
/// so the rep can enter the values by hand.

abstract class _$ScanProcessor extends $Notifier<void> {
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
