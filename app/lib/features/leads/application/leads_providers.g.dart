// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leads_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(leadList)
final leadListProvider = LeadListFamily._();

final class LeadListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Lead>>,
          List<Lead>,
          Stream<List<Lead>>
        >
    with $FutureModifier<List<Lead>>, $StreamProvider<List<Lead>> {
  LeadListProvider._({
    required LeadListFamily super.from,
    required LeadFilter super.argument,
  }) : super(
         retry: null,
         name: r'leadListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadListHash();

  @override
  String toString() {
    return r'leadListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Lead>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Lead>> create(Ref ref) {
    final argument = this.argument as LeadFilter;
    return leadList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadListHash() => r'3fd1ac93681c5cd3d0faab5a880c739a70c00c97';

final class LeadListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Lead>>, LeadFilter> {
  LeadListFamily._()
    : super(
        retry: null,
        name: r'leadListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadListProvider call(LeadFilter filter) =>
      LeadListProvider._(argument: filter, from: this);

  @override
  String toString() => r'leadListProvider';
}

@ProviderFor(lead)
final leadProvider = LeadFamily._();

final class LeadProvider
    extends $FunctionalProvider<AsyncValue<Lead?>, Lead?, Stream<Lead?>>
    with $FutureModifier<Lead?>, $StreamProvider<Lead?> {
  LeadProvider._({
    required LeadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadHash();

  @override
  String toString() {
    return r'leadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Lead?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Lead?> create(Ref ref) {
    final argument = this.argument as String;
    return lead(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadHash() => r'5c6f088ae6bd03f7f575e697f55246ecda2e319b';

final class LeadFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Lead?>, String> {
  LeadFamily._()
    : super(
        retry: null,
        name: r'leadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadProvider call(String id) => LeadProvider._(argument: id, from: this);

  @override
  String toString() => r'leadProvider';
}

@ProviderFor(leadStatusCounts)
final leadStatusCountsProvider = LeadStatusCountsProvider._();

final class LeadStatusCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<LeadStatus, int>>,
          Map<LeadStatus, int>,
          Stream<Map<LeadStatus, int>>
        >
    with
        $FutureModifier<Map<LeadStatus, int>>,
        $StreamProvider<Map<LeadStatus, int>> {
  LeadStatusCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadStatusCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadStatusCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<LeadStatus, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<LeadStatus, int>> create(Ref ref) {
    return leadStatusCounts(ref);
  }
}

String _$leadStatusCountsHash() => r'62dcbe29ce9d72dd6f395db89c76b4248404a59c';

@ProviderFor(todaysFollowUps)
final todaysFollowUpsProvider = TodaysFollowUpsProvider._();

final class TodaysFollowUpsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Lead>>,
          List<Lead>,
          Stream<List<Lead>>
        >
    with $FutureModifier<List<Lead>>, $StreamProvider<List<Lead>> {
  TodaysFollowUpsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysFollowUpsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysFollowUpsHash();

  @$internal
  @override
  $StreamProviderElement<List<Lead>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Lead>> create(Ref ref) {
    return todaysFollowUps(ref);
  }
}

String _$todaysFollowUpsHash() => r'9ff36180ea56cf9e9e0203ce2b7056fc663edc9d';

@ProviderFor(leadsThisMonth)
final leadsThisMonthProvider = LeadsThisMonthProvider._();

final class LeadsThisMonthProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  LeadsThisMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadsThisMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadsThisMonthHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return leadsThisMonth(ref);
  }
}

String _$leadsThisMonthHash() => r'ec7f9e89c32caa62a09a06b52ad05536266ea626';

@ProviderFor(pendingSyncIds)
final pendingSyncIdsProvider = PendingSyncIdsProvider._();

final class PendingSyncIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  PendingSyncIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSyncIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSyncIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return pendingSyncIds(ref);
  }
}

String _$pendingSyncIdsHash() => r'58b530b4a1cb54d2af1b2ede24162b667afb5f45';

@ProviderFor(team)
final teamProvider = TeamProvider._();

final class TeamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TeamMember>>,
          List<TeamMember>,
          Stream<List<TeamMember>>
        >
    with $FutureModifier<List<TeamMember>>, $StreamProvider<List<TeamMember>> {
  TeamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamHash();

  @$internal
  @override
  $StreamProviderElement<List<TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TeamMember>> create(Ref ref) {
    return team(ref);
  }
}

String _$teamHash() => r'410814b63b799a26c82a32002cea3510769afb90';

@ProviderFor(leadPhotos)
final leadPhotosProvider = LeadPhotosFamily._();

final class LeadPhotosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LeadPhoto>>,
          List<LeadPhoto>,
          Stream<List<LeadPhoto>>
        >
    with $FutureModifier<List<LeadPhoto>>, $StreamProvider<List<LeadPhoto>> {
  LeadPhotosProvider._({
    required LeadPhotosFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadPhotosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadPhotosHash();

  @override
  String toString() {
    return r'leadPhotosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LeadPhoto>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LeadPhoto>> create(Ref ref) {
    final argument = this.argument as String;
    return leadPhotos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadPhotosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadPhotosHash() => r'ec438fec28f88e06a7c39f20c417c642fecf8418';

final class LeadPhotosFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LeadPhoto>>, String> {
  LeadPhotosFamily._()
    : super(
        retry: null,
        name: r'leadPhotosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadPhotosProvider call(String leadId) =>
      LeadPhotosProvider._(argument: leadId, from: this);

  @override
  String toString() => r'leadPhotosProvider';
}

/// The signed-in member (null while signed out).

@ProviderFor(currentMember)
final currentMemberProvider = CurrentMemberProvider._();

/// The signed-in member (null while signed out).

final class CurrentMemberProvider
    extends $FunctionalProvider<Ready?, Ready?, Ready?>
    with $Provider<Ready?> {
  /// The signed-in member (null while signed out).
  CurrentMemberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMemberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMemberHash();

  @$internal
  @override
  $ProviderElement<Ready?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Ready? create(Ref ref) {
    return currentMember(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Ready? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Ready?>(value),
    );
  }
}

String _$currentMemberHash() => r'bc1ecba4c310c4629f8b79baca26207314bafbb0';
