// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(surveyRepository)
final surveyRepositoryProvider = SurveyRepositoryProvider._();

final class SurveyRepositoryProvider
    extends
        $FunctionalProvider<
          SurveyRepository,
          SurveyRepository,
          SurveyRepository
        >
    with $Provider<SurveyRepository> {
  SurveyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'surveyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$surveyRepositoryHash();

  @$internal
  @override
  $ProviderElement<SurveyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SurveyRepository create(Ref ref) {
    return surveyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SurveyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SurveyRepository>(value),
    );
  }
}

String _$surveyRepositoryHash() => r'aa0ea6b0721292b717c4af6e83cfc11a5e2e55f9';

@ProviderFor(leadSite)
final leadSiteProvider = LeadSiteFamily._();

final class LeadSiteProvider
    extends $FunctionalProvider<AsyncValue<Site?>, Site?, Stream<Site?>>
    with $FutureModifier<Site?>, $StreamProvider<Site?> {
  LeadSiteProvider._({
    required LeadSiteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadSiteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadSiteHash();

  @override
  String toString() {
    return r'leadSiteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Site?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Site?> create(Ref ref) {
    final argument = this.argument as String;
    return leadSite(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadSiteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadSiteHash() => r'468c657b3290a6ba24b60197eb6ea5a423109800';

final class LeadSiteFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Site?>, String> {
  LeadSiteFamily._()
    : super(
        retry: null,
        name: r'leadSiteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadSiteProvider call(String leadId) =>
      LeadSiteProvider._(argument: leadId, from: this);

  @override
  String toString() => r'leadSiteProvider';
}
