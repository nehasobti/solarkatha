// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leads_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(leadsRepository)
final leadsRepositoryProvider = LeadsRepositoryProvider._();

final class LeadsRepositoryProvider
    extends
        $FunctionalProvider<LeadsRepository, LeadsRepository, LeadsRepository>
    with $Provider<LeadsRepository> {
  LeadsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leadsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leadsRepositoryHash();

  @$internal
  @override
  $ProviderElement<LeadsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LeadsRepository create(Ref ref) {
    return leadsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeadsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeadsRepository>(value),
    );
  }
}

String _$leadsRepositoryHash() => r'6fe4a8a7464e0b5efae82868c9400f50f0a2925d';
