// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'bbc768aa8c8e4a3b80ecee56bad49d1d3eba233f';

@ProviderFor(dashboardStats)
final dashboardStatsProvider = DashboardStatsProvider._();

final class DashboardStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardStats>,
          DashboardStats,
          Stream<DashboardStats>
        >
    with $FutureModifier<DashboardStats>, $StreamProvider<DashboardStats> {
  DashboardStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStatsHash();

  @$internal
  @override
  $StreamProviderElement<DashboardStats> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DashboardStats> create(Ref ref) {
    return dashboardStats(ref);
  }
}

String _$dashboardStatsHash() => r'db9d8e6cd36d6a6512aa857ff455dbca74c64516';

@ProviderFor(members)
final membersProvider = MembersProvider._();

final class MembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Member>>,
          List<Member>,
          Stream<List<Member>>
        >
    with $FutureModifier<List<Member>>, $StreamProvider<List<Member>> {
  MembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membersHash();

  @$internal
  @override
  $StreamProviderElement<List<Member>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Member>> create(Ref ref) {
    return members(ref);
  }
}

String _$membersHash() => r'a00181229bc97362521317a63a106978c40086da';

@ProviderFor(configRows)
final configRowsProvider = ConfigRowsFamily._();

final class ConfigRowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConfigRow>>,
          List<ConfigRow>,
          Stream<List<ConfigRow>>
        >
    with $FutureModifier<List<ConfigRow>>, $StreamProvider<List<ConfigRow>> {
  ConfigRowsProvider._({
    required ConfigRowsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'configRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$configRowsHash();

  @override
  String toString() {
    return r'configRowsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<ConfigRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConfigRow>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return configRows(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ConfigRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$configRowsHash() => r'81fbf0fcd08ce29568bd21d7c3d131f8d93d4f13';

final class ConfigRowsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ConfigRow>>, (String, String)> {
  ConfigRowsFamily._()
    : super(
        retry: null,
        name: r'configRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConfigRowsProvider call(String table, String orderBy) =>
      ConfigRowsProvider._(argument: (table, orderBy), from: this);

  @override
  String toString() => r'configRowsProvider';
}

@ProviderFor(company)
final companyProvider = CompanyFamily._();

final class CompanyProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Object?>?>,
          Map<String, Object?>?,
          Stream<Map<String, Object?>?>
        >
    with
        $FutureModifier<Map<String, Object?>?>,
        $StreamProvider<Map<String, Object?>?> {
  CompanyProvider._({
    required CompanyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'companyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$companyHash();

  @override
  String toString() {
    return r'companyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, Object?>?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Object?>?> create(Ref ref) {
    final argument = this.argument as String;
    return company(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CompanyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$companyHash() => r'57bfd093c431ef01a5c4df468a4d3c52a6f4f1fd';

final class CompanyFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, Object?>?>, String> {
  CompanyFamily._()
    : super(
        retry: null,
        name: r'companyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CompanyProvider call(String id) =>
      CompanyProvider._(argument: id, from: this);

  @override
  String toString() => r'companyProvider';
}
