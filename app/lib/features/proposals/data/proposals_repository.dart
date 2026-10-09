import 'dart:convert';
import 'dart:typed_data';

import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/powersync/powersync_providers.dart';
import '../../../data/powersync/schema.dart';
import '../../../data/supabase/supabase_providers.dart';
import '../domain/proposal.dart';

part 'proposals_repository.g.dart';

const _uuid = Uuid();
String _now() => DateTime.now().toUtc().toIso8601String();

/// Thrown when a server step needs the internet or the record to sync first.
class ServerStepException implements Exception {
  ServerStepException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProposalsRepository {
  ProposalsRepository(this._db, this._client);

  final PowerSyncDatabase _db;
  final SupabaseClient _client;

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  Stream<List<Product>> watchProducts({bool activeOnly = false}) => _db
      .watch(
        'SELECT * FROM products WHERE deleted_at IS NULL '
        '${activeOnly ? 'AND active = 1 ' : ''}'
        'ORDER BY type, brand, model',
      )
      .map((rows) => rows.map(Product.fromRow).toList());

  Future<void> saveProduct(Product p, {required String companyId}) async {
    final row = {...p.toRow(), 'updated_at': _now()};
    final exists = await _db.getOptional(
      'SELECT id FROM products WHERE id = ?',
      [p.id],
    );
    if (exists != null) {
      await _db.execute(
        'UPDATE products SET ${row.keys.map((k) => '$k = ?').join(', ')} '
        'WHERE id = ?',
        [...row.values, p.id],
      );
    } else {
      final all = {
        ...row,
        'id': p.id,
        'company_id': companyId,
        'created_at': _now(),
      };
      await _db.execute(
        'INSERT INTO products (${all.keys.join(', ')}) '
        'VALUES (${List.filled(all.length, '?').join(', ')})',
        all.values.toList(),
      );
    }
  }

  Future<void> deleteProduct(String id) => _db.execute(
    'UPDATE products SET deleted_at = ?, updated_at = ? WHERE id = ?',
    [_now(), _now(), id],
  );

  // ---------------------------------------------------------------------------
  // Proposals
  // ---------------------------------------------------------------------------

  Stream<List<Proposal>> watchProposals(String leadId) => _db
      .watch(
        'SELECT * FROM $proposalsTable WHERE lead_id = ? AND deleted_at IS NULL '
        'ORDER BY version DESC',
        parameters: [leadId],
      )
      .map((rows) => rows.map(Proposal.fromRow).toList());

  Stream<Proposal?> watchProposal(String id) => _db
      .watch('SELECT * FROM $proposalsTable WHERE id = ?', parameters: [id])
      .map((rows) => rows.isEmpty ? null : Proposal.fromRow(rows.first));

  Stream<List<Payment>> watchPayments(String proposalId) => _db
      .watch(
        'SELECT * FROM payments WHERE proposal_id = ? ORDER BY created_at DESC',
        parameters: [proposalId],
      )
      .map((rows) => rows.map(Payment.fromRow).toList());

  /// Photos taken for the lead (compliance: at least 4 site photos).
  Future<int> photoCount(String leadId) async {
    final r = await _db.get(
      'SELECT COUNT(*) AS n FROM lead_photos WHERE lead_id = ? '
      "AND kind NOT IN ('bill', 'roof_layout') "
      'AND deleted_at IS NULL',
      [leadId],
    );
    return r['n'] as int;
  }

  /// A config value (company row wins over the default), decoded from JSON.
  Future<Object?> configValue(String key, String companyId) async {
    final rows = await _db.getAll(
      'SELECT company_id, value FROM app_config WHERE key = ?',
      [key],
    );
    final own = rows.where((r) => r['company_id'] == companyId).firstOrNull;
    final row = own ?? rows.where((r) => r['company_id'] == null).firstOrNull;
    if (row == null) return null;
    try {
      return jsonDecode(row['value']! as String);
    } catch (_) {
      return row['value'];
    }
  }

  Future<String> createProposal({
    required String leadId,
    required String companyId,
    required String userId,
    required ProposalDraft draft,
  }) async {
    final v = await _db.get(
      'SELECT COALESCE(MAX(version), 0) + 1 AS v FROM $proposalsTable '
      'WHERE lead_id = ?',
      [leadId],
    );
    final id = _uuid.v4();
    final row = {
      ...draft.toRow(),
      'id': id,
      'company_id': companyId,
      'lead_id': leadId,
      'version': v['v'],
      'status': ProposalStatus.draft.name,
      'created_by': userId,
      'created_at': _now(),
      'updated_at': _now(),
    };
    await _db.execute(
      'INSERT INTO $proposalsTable (${row.keys.join(', ')}) '
      'VALUES (${List.filled(row.length, '?').join(', ')})',
      row.values.toList(),
    );
    return id;
  }

  Future<void> updateProposal(String id, ProposalDraft draft) =>
      _update(id, {...draft.toRow(), 'updated_at': _now()});

  /// Marks the proposal sent and moves an early-stage lead to "proposal sent".
  Future<void> markSent(Proposal p) async {
    await _db.writeTransaction((tx) async {
      if (p.status == ProposalStatus.draft) {
        await tx.execute(
          'UPDATE $proposalsTable SET status = ?, sent_at = ?, updated_at = ? '
          'WHERE id = ?',
          [ProposalStatus.sent.name, _now(), _now(), p.id],
        );
      }
      await tx.execute(
        "UPDATE leads SET status = 'proposal_sent', updated_at = ? "
        "WHERE id = ? AND status IN ('new', 'surveyed')",
        [_now(), p.leadId],
      );
    });
  }

  /// Stores the customer's signature; the proposal is signed and the lead won.
  Future<void> sign(Proposal p, Uint8List png) async {
    final dataUrl = 'data:image/png;base64,${base64Encode(png)}';
    await _db.writeTransaction((tx) async {
      await tx.execute(
        'UPDATE $proposalsTable SET signature_png = ?, signed_at = ?, status = ?, '
        'sent_at = COALESCE(sent_at, ?), updated_at = ? WHERE id = ?',
        [dataUrl, _now(), ProposalStatus.signed.name, _now(), _now(), p.id],
      );
      await tx.execute(
        "UPDATE leads SET status = 'won', updated_at = ? WHERE id = ?",
        [_now(), p.leadId],
      );
    });
  }

  Future<void> deleteProposal(String id) =>
      _update(id, {'deleted_at': _now(), 'updated_at': _now()});

  Future<void> _update(String id, Map<String, Object?> fields) => _db.execute(
    'UPDATE $proposalsTable SET ${fields.keys.map((k) => '$k = ?').join(', ')} '
    'WHERE id = ?',
    [...fields.values, id],
  );

  /// True while the proposal still has changes waiting to upload.
  Future<bool> hasPendingUpload(String id) async {
    final r = await _db.get(
      "SELECT COUNT(*) AS n FROM ps_crud WHERE json_extract(data, '\$.id') = ?",
      [id],
    );
    return (r['n'] as int) > 0;
  }

  // ---------------------------------------------------------------------------
  // Server steps (need internet)
  // ---------------------------------------------------------------------------

  Future<T> _invoke<T>(String fn, Map<String, Object?> body) async {
    try {
      final res = await _client.functions.invoke(fn, body: body);
      return res.data as T;
    } on FunctionException catch (e) {
      final d = e.details;
      throw ServerStepException(
        d is Map && d['message'] is String
            ? d['message'] as String
            : (e.reasonPhrase ?? 'Error ${e.status}'),
      );
    }
  }

  /// Generates the PDF on the server; returns a link valid for 7 days.
  Future<String> requestPdf(String proposalId) async {
    final data = await _invoke<Map<String, dynamic>>('proposal-pdf-request', {
      'proposal_id': proposalId,
    });
    return data['url']! as String;
  }

  Future<Uint8List> downloadPdf(String path) =>
      _client.storage.from('documents').download(path);

  /// Creates a Razorpay payment link; returns the short URL and amount.
  Future<(String, double)> createPaymentLink(
    String proposalId, {
    double? amount,
    String kind = 'advance',
  }) async {
    final data = await _invoke<Map<String, dynamic>>('payment-link', {
      'proposal_id': proposalId,
      'kind': kind,
      'amount': ?amount,
    });
    return (data['short_url']! as String, (data['amount']! as num).toDouble());
  }
}

@Riverpod(keepAlive: true)
ProposalsRepository proposalsRepository(Ref ref) => ProposalsRepository(
  ref.watch(powerSyncDbProvider),
  ref.watch(supabaseClientProvider),
);

@riverpod
Stream<List<Product>> products(Ref ref, {bool activeOnly = false}) => ref
    .watch(proposalsRepositoryProvider)
    .watchProducts(activeOnly: activeOnly);

@riverpod
Stream<List<Proposal>> leadProposals(Ref ref, String leadId) =>
    ref.watch(proposalsRepositoryProvider).watchProposals(leadId);

@riverpod
Stream<Proposal?> proposal(Ref ref, String id) =>
    ref.watch(proposalsRepositoryProvider).watchProposal(id);

@riverpod
Stream<List<Payment>> proposalPayments(Ref ref, String proposalId) =>
    ref.watch(proposalsRepositoryProvider).watchPayments(proposalId);
