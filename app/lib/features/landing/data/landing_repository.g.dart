// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'landing_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(landingRepository)
final landingRepositoryProvider = LandingRepositoryProvider._();

final class LandingRepositoryProvider
    extends
        $FunctionalProvider<
          LandingRepository,
          LandingRepository,
          LandingRepository
        >
    with $Provider<LandingRepository> {
  LandingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'landingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$landingRepositoryHash();

  @$internal
  @override
  $ProviderElement<LandingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LandingRepository create(Ref ref) {
    return landingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LandingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LandingRepository>(value),
    );
  }
}

String _$landingRepositoryHash() => r'de22ae14b210848370eaad3a8b0ba24b30902a2d';

@ProviderFor(publicSizingConfig)
final publicSizingConfigProvider = PublicSizingConfigProvider._();

final class PublicSizingConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<SizingConfig>,
          SizingConfig,
          FutureOr<SizingConfig>
        >
    with $FutureModifier<SizingConfig>, $FutureProvider<SizingConfig> {
  PublicSizingConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicSizingConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publicSizingConfigHash();

  @$internal
  @override
  $FutureProviderElement<SizingConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SizingConfig> create(Ref ref) {
    return publicSizingConfig(ref);
  }
}

String _$publicSizingConfigHash() =>
    r'1d1b24ff4301ff9818f8c78aa9682893b4344572';

@ProviderFor(latestNews)
final latestNewsProvider = LatestNewsFamily._();

final class LatestNewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NewsItem>>,
          List<NewsItem>,
          FutureOr<List<NewsItem>>
        >
    with $FutureModifier<List<NewsItem>>, $FutureProvider<List<NewsItem>> {
  LatestNewsProvider._({
    required LatestNewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'latestNewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$latestNewsHash();

  @override
  String toString() {
    return r'latestNewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<NewsItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NewsItem>> create(Ref ref) {
    final argument = this.argument as String;
    return latestNews(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestNewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestNewsHash() => r'c96f43cd1abad41ad06ba7b36d88fd4b8973d89c';

final class LatestNewsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<NewsItem>>, String> {
  LatestNewsFamily._()
    : super(
        retry: null,
        name: r'latestNewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LatestNewsProvider call(String lang) =>
      LatestNewsProvider._(argument: lang, from: this);

  @override
  String toString() => r'latestNewsProvider';
}
