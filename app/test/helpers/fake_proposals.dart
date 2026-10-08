import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:solarkatha/features/proposals/data/proposals_repository.dart';
import 'package:solarkatha/features/proposals/domain/proposal.dart';

const demoPanels = [
  Product(
    id: 'panel-dcr',
    companyId: 'c1',
    type: ProductType.panel,
    brand: 'Waaree',
    model: '540 DCR',
    wattPeak: 540,
    isDcr: true,
    almmListed: true,
    warrantyYears: 25,
    unitPrice: 16500,
  ),
  Product(
    id: 'panel-import',
    companyId: 'c1',
    type: ProductType.panel,
    brand: 'Generic',
    model: '550 imported',
    wattPeak: 550,
    unitPrice: 11000,
  ),
  Product(
    id: 'inv',
    companyId: 'c1',
    type: ProductType.inverter,
    brand: 'Polycab',
    model: '3 kW',
    approvedList: true,
    warrantyYears: 8,
    unitPrice: 28000,
  ),
];

/// In-memory proposals, products and payments.
class FakeProposalsRepository extends Mock implements ProposalsRepository {
  FakeProposalsRepository({
    List<Product> products = demoPanels,
    this.photos = 0,
  }) : _products = [...products];

  final List<Product> _products;
  final List<Proposal> proposals = [];
  int photos;
  final _changes = StreamController<void>.broadcast();
  int pdfRequests = 0;

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<List<Product>> watchProducts({bool activeOnly = false}) =>
      _live(() => _products.where((p) => !activeOnly || p.active).toList());

  @override
  Stream<List<Proposal>> watchProposals(String leadId) =>
      _live(() => proposals.where((p) => p.leadId == leadId).toList());

  @override
  Stream<Proposal?> watchProposal(String id) =>
      _live(() => proposals.where((p) => p.id == id).firstOrNull);

  @override
  Stream<List<Payment>> watchPayments(String proposalId) =>
      Stream.value(const []);

  @override
  Future<int> photoCount(String leadId) async => photos;

  @override
  Future<Object?> configValue(String key, String companyId) async =>
      switch (key) {
        'advance_pct' => 20,
        _ => 'Namaste {customer_name}: {pdf_link}',
      };

  @override
  Future<bool> hasPendingUpload(String id) async => false;

  Proposal _fromDraft(String id, String leadId, int version, ProposalDraft d) =>
      Proposal.fromRow({
        ...d.toRow(),
        'id': id,
        'company_id': 'c1',
        'lead_id': leadId,
        'version': version,
        'status': 'draft',
      });

  @override
  Future<String> createProposal({
    required String leadId,
    required String companyId,
    required String userId,
    required ProposalDraft draft,
  }) async {
    final id = 'prop-${proposals.length + 1}';
    proposals.add(_fromDraft(id, leadId, proposals.length + 1, draft));
    _changes.add(null);
    return id;
  }

  @override
  Future<void> updateProposal(String id, ProposalDraft draft) async {
    final i = proposals.indexWhere((p) => p.id == id);
    proposals[i] = _fromDraft(
      id,
      proposals[i].leadId,
      proposals[i].version,
      draft,
    );
    _changes.add(null);
  }

  @override
  Future<void> sign(Proposal p, Uint8List png) async {}

  @override
  Future<String> requestPdf(String proposalId) async {
    pdfRequests++;
    return 'https://example.test/p.pdf';
  }
}
