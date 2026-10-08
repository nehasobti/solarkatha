// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bills_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(leadBills)
final leadBillsProvider = LeadBillsFamily._();

final class LeadBillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Bill>>,
          List<Bill>,
          Stream<List<Bill>>
        >
    with $FutureModifier<List<Bill>>, $StreamProvider<List<Bill>> {
  LeadBillsProvider._({
    required LeadBillsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadBillsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadBillsHash();

  @override
  String toString() {
    return r'leadBillsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Bill>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Bill>> create(Ref ref) {
    final argument = this.argument as String;
    return leadBills(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadBillsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadBillsHash() => r'41abb42b703214470f344f44b33f306f9ad21d3c';

final class LeadBillsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Bill>>, String> {
  LeadBillsFamily._()
    : super(
        retry: null,
        name: r'leadBillsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadBillsProvider call(String leadId) =>
      LeadBillsProvider._(argument: leadId, from: this);

  @override
  String toString() => r'leadBillsProvider';
}

@ProviderFor(leadScans)
final leadScansProvider = LeadScansFamily._();

final class LeadScansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScanJob>>,
          List<ScanJob>,
          Stream<List<ScanJob>>
        >
    with $FutureModifier<List<ScanJob>>, $StreamProvider<List<ScanJob>> {
  LeadScansProvider._({
    required LeadScansFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadScansProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadScansHash();

  @override
  String toString() {
    return r'leadScansProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ScanJob>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ScanJob>> create(Ref ref) {
    final argument = this.argument as String;
    return leadScans(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadScansProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadScansHash() => r'12622cd0c9c7688c44c11a80a47db3bc6c426984';

final class LeadScansFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ScanJob>>, String> {
  LeadScansFamily._()
    : super(
        retry: null,
        name: r'leadScansProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadScansProvider call(String leadId) =>
      LeadScansProvider._(argument: leadId, from: this);

  @override
  String toString() => r'leadScansProvider';
}
