// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposals_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(proposalsRepository)
final proposalsRepositoryProvider = ProposalsRepositoryProvider._();

final class ProposalsRepositoryProvider
    extends
        $FunctionalProvider<
          ProposalsRepository,
          ProposalsRepository,
          ProposalsRepository
        >
    with $Provider<ProposalsRepository> {
  ProposalsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proposalsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proposalsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProposalsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProposalsRepository create(Ref ref) {
    return proposalsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProposalsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProposalsRepository>(value),
    );
  }
}

String _$proposalsRepositoryHash() =>
    r'806b8b40a9d05d17a2756c044e761874897c3e1c';

@ProviderFor(products)
final productsProvider = ProductsFamily._();

final class ProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          Stream<List<Product>>
        >
    with $FutureModifier<List<Product>>, $StreamProvider<List<Product>> {
  ProductsProvider._({
    required ProductsFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'productsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productsHash();

  @override
  String toString() {
    return r'productsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Product>> create(Ref ref) {
    final argument = this.argument as bool;
    return products(ref, activeOnly: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productsHash() => r'd2159c469bdfc307b9384c116c45d6f6cb067a78';

final class ProductsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Product>>, bool> {
  ProductsFamily._()
    : super(
        retry: null,
        name: r'productsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductsProvider call({bool activeOnly = false}) =>
      ProductsProvider._(argument: activeOnly, from: this);

  @override
  String toString() => r'productsProvider';
}

@ProviderFor(leadProposals)
final leadProposalsProvider = LeadProposalsFamily._();

final class LeadProposalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Proposal>>,
          List<Proposal>,
          Stream<List<Proposal>>
        >
    with $FutureModifier<List<Proposal>>, $StreamProvider<List<Proposal>> {
  LeadProposalsProvider._({
    required LeadProposalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadProposalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadProposalsHash();

  @override
  String toString() {
    return r'leadProposalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Proposal>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Proposal>> create(Ref ref) {
    final argument = this.argument as String;
    return leadProposals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadProposalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadProposalsHash() => r'5dd2b4eaad7b3b6b0e5d0910479c50a5a5eec11e';

final class LeadProposalsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Proposal>>, String> {
  LeadProposalsFamily._()
    : super(
        retry: null,
        name: r'leadProposalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadProposalsProvider call(String leadId) =>
      LeadProposalsProvider._(argument: leadId, from: this);

  @override
  String toString() => r'leadProposalsProvider';
}

@ProviderFor(proposal)
final proposalProvider = ProposalFamily._();

final class ProposalProvider
    extends
        $FunctionalProvider<AsyncValue<Proposal?>, Proposal?, Stream<Proposal?>>
    with $FutureModifier<Proposal?>, $StreamProvider<Proposal?> {
  ProposalProvider._({
    required ProposalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'proposalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proposalHash();

  @override
  String toString() {
    return r'proposalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Proposal?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Proposal?> create(Ref ref) {
    final argument = this.argument as String;
    return proposal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProposalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proposalHash() => r'425aae885b96a17bae0a2e1b4bddda92155a784b';

final class ProposalFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Proposal?>, String> {
  ProposalFamily._()
    : super(
        retry: null,
        name: r'proposalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProposalProvider call(String id) =>
      ProposalProvider._(argument: id, from: this);

  @override
  String toString() => r'proposalProvider';
}

@ProviderFor(proposalPayments)
final proposalPaymentsProvider = ProposalPaymentsFamily._();

final class ProposalPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Payment>>,
          List<Payment>,
          Stream<List<Payment>>
        >
    with $FutureModifier<List<Payment>>, $StreamProvider<List<Payment>> {
  ProposalPaymentsProvider._({
    required ProposalPaymentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'proposalPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proposalPaymentsHash();

  @override
  String toString() {
    return r'proposalPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Payment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Payment>> create(Ref ref) {
    final argument = this.argument as String;
    return proposalPayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProposalPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proposalPaymentsHash() => r'81d89190bf8834cf34f3b35d05cf30d00275b593';

final class ProposalPaymentsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Payment>>, String> {
  ProposalPaymentsFamily._()
    : super(
        retry: null,
        name: r'proposalPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProposalPaymentsProvider call(String proposalId) =>
      ProposalPaymentsProvider._(argument: proposalId, from: this);

  @override
  String toString() => r'proposalPaymentsProvider';
}
